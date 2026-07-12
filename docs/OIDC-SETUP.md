# OIDC setup: Azure ↔ GitHub Actions

This module's CI authenticates to Azure via OpenID Connect (OIDC) — no
client secrets are stored in GitHub. Follow this guide once per module
repository.

## Prerequisites

- Azure CLI installed and logged in: `az login`
- Owner or User Access Administrator on the target subscription
- GitHub CLI (`gh`) authenticated: `gh auth login`

## Step 1: Create the App Registration

```bash
APP_NAME="github-actions-<module-name>"    # e.g. github-actions-keyvault-private

az ad app create --display-name "$APP_NAME"
APP_ID=$(az ad app list --display-name "$APP_NAME" --query "[0].appId" -o tsv)
OBJECT_ID=$(az ad app list --display-name "$APP_NAME" --query "[0].id" -o tsv)

echo "App ID (client ID): $APP_ID"
echo "Object ID: $OBJECT_ID"
```

## Step 2: Create the Service Principal

```bash
az ad sp create --id "$APP_ID"
SP_OBJECT_ID=$(az ad sp show --id "$APP_ID" --query "id" -o tsv)
```

## Step 3: Grant Contributor at subscription scope

Terratest needs to create and destroy resource groups. Contributor at
subscription scope is the minimum viable role.

```bash
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

az role assignment create \
  --assignee-object-id "$SP_OBJECT_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

## Step 4: Configure the federated credentials

We create one credential per GitHub event type. Adjust `REPO_OWNER` and
`REPO_NAME`.

```bash
REPO_OWNER="MAnouerB"
REPO_NAME="terraform-azurerm-<module-name>"

# For pushes to main
az ad app federated-credential create \
  --id "$OBJECT_ID" \
  --parameters "{
    \"name\": \"github-push-main\",
    \"issuer\": \"https://token.actions.githubusercontent.com\",
    \"subject\": \"repo:$REPO_OWNER/$REPO_NAME:ref:refs/heads/main\",
    \"audiences\": [\"api://AzureADTokenExchange\"]
  }"

# For pull requests (any)
az ad app federated-credential create \
  --id "$OBJECT_ID" \
  --parameters "{
    \"name\": \"github-pull-request\",
    \"issuer\": \"https://token.actions.githubusercontent.com\",
    \"subject\": \"repo:$REPO_OWNER/$REPO_NAME:pull_request\",
    \"audiences\": [\"api://AzureADTokenExchange\"]
  }"

# For tags (releases)
az ad app federated-credential create \
  --id "$OBJECT_ID" \
  --parameters "{
    \"name\": \"github-tag\",
    \"issuer\": \"https://token.actions.githubusercontent.com\",
    \"subject\": \"repo:$REPO_OWNER/$REPO_NAME:ref:refs/tags/v*\",
    \"audiences\": [\"api://AzureADTokenExchange\"]
  }"
```

## Step 5: Set GitHub secrets

```bash
gh secret set AZURE_CLIENT_ID       --body "$APP_ID"       --repo "$REPO_OWNER/$REPO_NAME"
gh secret set AZURE_TENANT_ID       --body "$TENANT_ID"    --repo "$REPO_OWNER/$REPO_NAME"
gh secret set AZURE_SUBSCRIPTION_ID --body "$SUBSCRIPTION_ID" --repo "$REPO_OWNER/$REPO_NAME"

# Infracost API key (get one at https://www.infracost.io/, free tier)
gh secret set INFRACOST_API_KEY --body "<your-infracost-api-key>" --repo "$REPO_OWNER/$REPO_NAME"
```

## Step 6: Verify

Trigger the Terratest workflow manually:

```bash
gh workflow run terratest.yml --repo "$REPO_OWNER/$REPO_NAME"
gh run watch --repo "$REPO_OWNER/$REPO_NAME"
```

The first run should authenticate to Azure without any client secret in
your repo settings.

## Teardown (when retiring a module)

```bash
az ad app delete --id "$APP_ID"
```

## Security notes

- Federated credentials scope the token to specific GitHub events. A leaked
  workflow file in a fork cannot obtain a token to your subscription.
- Never fall back to a client secret — if OIDC fails, fix the federated
  credential rather than adding `ARM_CLIENT_SECRET`.
- The `Contributor` role at subscription scope is broad. For stricter
  environments, scope to a dedicated resource group and pre-provision it.