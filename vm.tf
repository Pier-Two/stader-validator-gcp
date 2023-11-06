#####################################################################
#region:  Use VM Module
module "vm" {
  depends_on = [module.subnet]
  source = "./modules/vm"
  dependencies = var.dependencies
  vm = [
    merge(local.vm, {
      id           = 1
      zone         = "${var.dependencies.gcp.region}-a"
      name         = "${var.name_prefix}-1"
    })
  ]

  network = merge(
    local.network.subnet_1,
    {
    }
  )

}
#endregion
#####################################################################