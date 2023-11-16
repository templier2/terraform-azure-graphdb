data "azurerm_resource_group" "graphdb" {
  name = var.resource_group_name
}

data "azurerm_user_assigned_identity" "graphdb-instances" {
  name                = var.identity_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault" "graphdb" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

resource "random_password" "graphdb-cluster-token" {
  count   = var.graphdb_cluster_token != null ? 0 : 1
  length  = 16
  special = true
}

locals {
  graphdb_cluster_token = var.graphdb_cluster_token != null ? var.graphdb_cluster_token : random_password.graphdb-cluster-token[0].result
}

resource "azurerm_key_vault_secret" "graphdb-license" {
  key_vault_id = data.azurerm_key_vault.graphdb.id

  name  = var.graphdb_license_secret_name
  value = filebase64(var.graphdb_license_path)

  tags = var.tags
}

resource "azurerm_key_vault_secret" "graphdb-cluster-token" {
  count = var.graphdb_java_options != null ? 1 : 0

  key_vault_id = data.azurerm_key_vault.graphdb.id

  name  = var.graphdb_cluster_token_name
  value = base64encode(local.graphdb_cluster_token)

  tags = var.tags
}

resource "azurerm_key_vault_secret" "graphdb-properties" {
  count = var.graphdb_properties_path != null ? 1 : 0

  key_vault_id = data.azurerm_key_vault.graphdb.id

  name  = var.graphdb_properties_secret_name
  value = filebase64(var.graphdb_properties_path)

  tags = var.tags
}

resource "azurerm_key_vault_secret" "graphdb-java-options" {
  count = var.graphdb_java_options != null ? 1 : 0

  key_vault_id = data.azurerm_key_vault.graphdb.id

  name  = var.graphdb_java_options_secret_name
  value = base64encode(var.graphdb_java_options)

  tags = var.tags
}

# TODO: Cannot assign the secret resource as scope for some reason... it doesn't show in the console and it does not work in the VMs
# TODO: Not the right place for this to be here if we cannot give more granular access

# Give rights to the provided identity to be able to read it from the vault
resource "azurerm_role_assignment" "graphdb-license-reader" {
  principal_id         = data.azurerm_user_assigned_identity.graphdb-instances.principal_id
  scope                = data.azurerm_key_vault.graphdb.id
  role_definition_name = "Reader"
}

# Give rights to the provided identity to actually get the secret value
resource "azurerm_role_assignment" "graphdb-license-secret-reader" {
  principal_id         = data.azurerm_user_assigned_identity.graphdb-instances.principal_id
  scope                = data.azurerm_key_vault.graphdb.id
  role_definition_name = "Key Vault Secrets User"
}

# TODO should be moved to vm module
resource "azurerm_role_assignment" "rg-contributor-role" {
  principal_id         = data.azurerm_user_assigned_identity.graphdb-instances.principal_id
  scope                = data.azurerm_resource_group.graphdb.id
  role_definition_name = "Contributor"
}
