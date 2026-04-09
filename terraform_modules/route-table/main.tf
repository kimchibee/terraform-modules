#-------------------------------------------------------------------------------
# Route Table — 분류: AVM-only (docs/AVM_COVERAGE.md)
# routes_legacy_mode = true 이면 경로는 azurerm_route 로 관리 (state 이전 용이)
#-------------------------------------------------------------------------------
module "avm" {
  source = "../../vendor/terraform-azurerm-avm-res-network-routetable-0.5.0"

  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name
  tags                = var.tags

  bgp_route_propagation_enabled = var.bgp_route_propagation_enabled

  routes_legacy_mode = var.routes_legacy_mode
  routes             = var.routes

  subnet_resource_ids = var.subnet_resource_ids

  enable_telemetry = var.enable_telemetry
}
