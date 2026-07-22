package test

import (
	"context"
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/keyvault/armkeyvault"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/network/armnetwork/v5"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestKeyVaultPrivateComplete deploys the complete example end-to-end on
// Azure and asserts the module produced the expected infrastructure.
//
// Scope: infrastructure-level assertions only (resource existence, tags,
// configuration, RBAC). No data-plane operations — the vault is private
// and requires a VNet-attached client to reach it. Data-plane testing
// is deferred to v0.2.0 with a jump box pattern.
func TestKeyVaultPrivateComplete(t *testing.T) {
	t.Parallel()

	// ---- Environment ----

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	require.NotEmpty(t, subscriptionID, "ARM_SUBSCRIPTION_ID must be set")

	// ---- Test parameters ----

	namePrefix := "kv" + strings.ToLower(random.UniqueId())
	location := "westeurope"

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/complete",
		Vars: map[string]interface{}{
			"name_prefix": namePrefix,
			"location":    location,
		},
		NoColor: true,
	}

	// ---- Cleanup FIRST (defer runs on function exit, even on failure) ----

	defer terraform.Destroy(t, terraformOptions)

	// ---- Deploy ----

	terraform.InitAndApply(t, terraformOptions)

	// ---- Read outputs ----

	keyVaultID := terraform.Output(t, terraformOptions, "key_vault_id")
	keyVaultName := terraform.Output(t, terraformOptions, "key_vault_name")
	keyVaultURI := terraform.Output(t, terraformOptions, "key_vault_uri")
	privateEndpointID := terraform.Output(t, terraformOptions, "private_endpoint_id")
	privateEndpointIP := terraform.Output(t, terraformOptions, "private_endpoint_ip_address")
	lawID := terraform.Output(t, terraformOptions, "log_analytics_workspace_id")

	// ---- Assertions: outputs ----

	assert.Contains(t, keyVaultID, "/subscriptions/"+subscriptionID, "Key Vault ID must belong to the target subscription")
	assert.Contains(t, keyVaultID, "/providers/Microsoft.KeyVault/vaults/", "Key Vault ID must reference a Key Vault resource")
	assert.Equal(t, "kv-"+namePrefix+"-weu-001", keyVaultName, "Key Vault name should follow the naming convention")
	assert.Equal(t, fmt.Sprintf("https://%s.vault.azure.net/", keyVaultName), keyVaultURI, "Vault URI should follow the standard Azure pattern")
	assert.Contains(t, privateEndpointID, "/providers/Microsoft.Network/privateEndpoints/", "Private endpoint ID must reference a PE resource")
	assert.NotEmpty(t, privateEndpointIP, "Private endpoint must have a private IP allocated")
	assert.True(t, strings.HasPrefix(privateEndpointIP, "10.0.1."), "Private endpoint IP must be within the subnet CIDR 10.0.1.0/24")
	assert.Contains(t, lawID, "/providers/Microsoft.OperationalInsights/workspaces/", "Log Analytics workspace ID must reference a workspace")

	// ---- Assertions: Azure SDK ----

	ctx := context.Background()
	cred, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err, "Failed to acquire Azure credentials")

	kvClient, err := armkeyvault.NewVaultsClient(subscriptionID, cred, nil)
	require.NoError(t, err, "Failed to create Key Vault SDK client")

	peClient, err := armnetwork.NewPrivateEndpointsClient(subscriptionID, cred, nil)
	require.NoError(t, err, "Failed to create Private Endpoint SDK client")

	resourceGroupName := fmt.Sprintf("rg-%s-weu-001", namePrefix)

	// Retry on Azure SDK reads — sometimes eventual consistency slows initial GETs.
	kvResp := retry.DoWithRetry(t, "get Key Vault via SDK", 5, 10*time.Second, func() (string, error) {
		resp, err := kvClient.Get(ctx, resourceGroupName, keyVaultName, nil)
		if err != nil {
			return "", err
		}
		if resp.Vault.Properties == nil {
			return "", fmt.Errorf("vault properties are nil")
		}
		return "ok", nil
	})
	require.Equal(t, "ok", kvResp)

	kvGet, err := kvClient.Get(ctx, resourceGroupName, keyVaultName, nil)
	require.NoError(t, err, "Failed to GET Key Vault")

	props := kvGet.Vault.Properties
	require.NotNil(t, props)

	// ---- Assertions: Key Vault properties ----

	assert.Equal(t, "standard", string(*props.SKU.Name), "Key Vault SKU should default to standard")
	assert.True(t, *props.EnableRbacAuthorization, "RBAC authorization must be enabled (ADR-001)")
	assert.True(t, *props.EnablePurgeProtection, "Purge protection must be enabled (ADR-003)")
	assert.Equal(t, int32(90), *props.SoftDeleteRetentionInDays, "Soft delete retention should default to 90 days")
	require.NotNil(t, props.PublicNetworkAccess, "PublicNetworkAccess must be set on the vault")
	assert.Equal(t, "Disabled", *props.PublicNetworkAccess, "Public network access must be disabled in the complete example")
	// ---- Assertions: Network ACLs ----

	require.NotNil(t, props.NetworkACLs, "Network ACLs must be configured")
	assert.Equal(t, armkeyvault.NetworkRuleActionDeny, *props.NetworkACLs.DefaultAction, "Network ACLs default action must be Deny")
	assert.Equal(t, armkeyvault.NetworkRuleBypassOptionsAzureServices, *props.NetworkACLs.Bypass, "Network ACLs bypass must allow Azure Services")

	// ---- Assertions: Tags ----

	tags := kvGet.Vault.Tags
	require.NotNil(t, tags, "Tags must be present on the Key Vault")

	assert.Equal(t, "terraform", derefString(tags["managed_by"]), "managed_by tag must be terraform")
	assert.Equal(t, "github.com/MAnouerB/terraform-azurerm-keyvault-private", derefString(tags["module_source"]), "module_source tag must reference the module repo")
	assert.Equal(t, "0.1.0", derefString(tags["module_version"]), "module_version tag must match the release")
	assert.Equal(t, "example", derefString(tags["environment"]), "environment tag from the example must be present")
	assert.Equal(t, "complete", derefString(tags["example"]), "example tag must identify this as the complete example")

	// ---- Assertions: Private Endpoint ----

	peGet, err := peClient.Get(ctx, resourceGroupName, keyVaultName+"-pe", nil)
	require.NoError(t, err, "Failed to GET Private Endpoint")

	require.NotNil(t, peGet.PrivateEndpoint.Properties)
	require.NotEmpty(t, peGet.PrivateEndpoint.Properties.PrivateLinkServiceConnections, "Private endpoint must have at least one service connection")

	connection := peGet.PrivateEndpoint.Properties.PrivateLinkServiceConnections[0]
	assert.Equal(t, keyVaultID, *connection.Properties.PrivateLinkServiceID, "PE must connect to the Key Vault we just created")
	require.NotEmpty(t, connection.Properties.GroupIDs, "PE must specify a subresource group ID")
	assert.Equal(t, "vault", *connection.Properties.GroupIDs[0], "PE subresource group must be 'vault' (Azure Key Vault convention)")
}

// derefString safely dereferences a *string returned by the Azure SDK.
// Azure SDK exposes many optional string fields as *string; direct
// access panics on nil, so we guard with this helper.
func derefString(s *string) string {
	if s == nil {
		return ""
	}
	return *s
}
