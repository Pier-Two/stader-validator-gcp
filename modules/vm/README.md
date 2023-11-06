## VM Module

Standard VM module to be used by every terraform deployment.

Other Terraform Projects will import a specific version of this module, allowing for version control.

```
# Pass in variables like this to the module
module "vm" {
  depends_on = [module.subnet]
  source     = "../../modules/vm"

  dependencies = var.dependencies

  name_prefix = var.name_prefix

  vm = [
    merge(local.vm, {
      id           = 1
      name         = "${var.name_prefix}-1"
      machine_type = "e2-micro"
    }),
    merge(local.vm, {
      id           = 2
      name         = "${var.name_prefix}-2"
      machine_type = "e2-micro"
      image        = "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2204-jammy-v20230605"
      boot_disk = {
        size = 15
        type = "pd-ssd"
      }
      allow_stopping_for_update = true
      deletion_protection       = false
      labels                    = null
      metadata = {
        startup-script-url = ""
      }
    })
  ]

  network = merge(
    local.network.subnet_1,
    {
    }
  )

}

```

```
# Chain Ansible Server Bootstrap
resource "null_resource" "ansible_vm_server" {
  for_each = { for s in module.vm.vm : s.id => s }

  depends_on = [module.subnet, module.vm]

  # Triggers ansible playbook to run if any trigger files or server data are modified
  triggers = {
    ansibleConfig = filesha256("../../modules/ansible/server/server.yaml"),
    vmImage       = jsonencode(each.value.image)
    vmDiskType    = jsonencode(each.value.boot_disk.type)
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Wait until SSH is ready'"
    ]
    connection {
      type        = "ssh"
      user        = var.ssh.user
      private_key = file("${var.ssh.private_key}")
      host        = each.value.name
    }
  }

  # Run playbook
  provisioner "local-exec" {
    command = "ansible-playbook -i ${each.value.name}, --private-key ${var.ssh.private_key} --user ${var.ssh.user} ../../modules/ansible/server/server.yaml"
  }
}
```

## Provision instructions

Copy and paste into your Terraform configuration, insert the variables, and run Terraform init:

```sh
module "<module_name>" {
  source          = ""
  instance_name   = "<instance_name>"
  service_account = "<service_account>"
  project_id      = "<project_id>"
}
```
