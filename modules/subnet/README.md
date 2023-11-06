## Subnet Module

Standard Subnet module to be used by every terraform deployment.

Other Terraform Projects will import a specific version of this module, allowing for version control.

Pass in variables for the subnet like the following:

```
module "subnet_1" {
source = "../../modules/subnet"

dependencies = var.dependencies

subnet = {
name = local.network.subnet_1.subnet.name
ip_cidr_range = local.network.subnet_1.subnet.ip_cidr_range
}

}
```
