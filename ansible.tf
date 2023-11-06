#####################################################################
# region: Server pre-setup

resource "null_resource" "ansible_vm_server_bootstrap" {
  for_each = { for s in module.vm.vm : s.id => s }

  depends_on = [module.subnet, module.vm]

  # Triggers ansible playbook to run if any trigger files or server data are modified
  triggers = {
    ansibleConfig   = filesha256("ansible/server/bootstrap.yaml"),
    additionalDisks = jsonencode(each.value.additional_disks),
    vmDiskType      = jsonencode(each.value.boot_disk.type)
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Wait until SSH is ready'"
    ]
    connection {
      type        = "ssh"
      user        = var.ssh.user
      private_key = file("${var.ssh.private_key}")
      host = each.value.name
    }
  }

  # Run playbook
  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook -i ${each.value.name}, \
      --private-key ${var.ssh.private_key} \
      --user ${var.ssh.user} \
      --extra-vars 'disks=${jsonencode(each.value.additional_disks)}' \
      ansible/server/bootstrap.yaml
    EOT
  }
}
# endregion
#####################################################################

#####################################################################
# region: Stader node setup

resource "null_resource" "ansible_vm_stader_setup" {
  for_each = { for s in module.vm.vm : s.id => s }

  depends_on = [module.vm, null_resource.ansible_vm_server_bootstrap]

  # Triggers ansible playbook to run if any trigger files or server data are modified
  triggers = {
    ansibleConfig = filesha256("ansible/app/templates/user-settings.yml.j2"),
    StaderConfig  = filesha256("ansible/app/stader.yaml"),
    vmDiskType    = jsonencode(each.value.boot_disk.type),
    app           = jsonencode(each.value.app)
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
    command = <<EOT
      ansible-playbook -i ${each.value.name}, \
      --private-key ${var.ssh.private_key} \
      --user ${var.ssh.user} \
      --extra-vars '${jsonencode(each.value)}' \
      ansible/app/stader.yaml
    EOT
  }
}
# endregion
#####################################################################

#####################################################################
# region: Resize Boot Disk
# Runs every time the boot disk size changes
resource "null_resource" "ansible_vm_resize_boot_disk" {
  for_each = { for s in module.vm.vm : s.id => s }

  depends_on = [module.vm, null_resource.ansible_vm_server_bootstrap]

  # Triggers ansible playbook to run if any trigger files are modified
  triggers = {
    vmDiskSize = jsonencode(each.value.boot_disk.size)
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
    command = <<EOT
      ansible-playbook -i ${each.value.name}, \
      --private-key '${var.ssh.private_key}' \
      --user ${var.ssh.user} \
      --extra-vars 'disk_name=dk-${each.value.name}' \
      --extra-vars 'partition_id=1' \
      ansible/server/resize-disk.yaml 
    EOT
  }

}

#endregion
#####################################################################

#####################################################################
# region: Resize data Disk
# Runs every time the data disk size changes
resource "null_resource" "ansible_vm_resize_data_disk" {
  for_each = { for s in module.vm.vm : s.id => s }

  depends_on = [module.vm, null_resource.ansible_vm_server_bootstrap]

  # Triggers ansible playbook to run if any trigger files are modified
  triggers = {
    vmDiskSize = jsonencode(each.value.additional_disks.data-1.size)
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
    command = <<EOT
      ansible-playbook -i ${each.value.name}, \
      --private-key '${var.ssh.private_key}' \
      --user ${var.ssh.user} \
      --extra-vars 'disk_name=data-1' \
      --extra-vars 'partition_id=1' \
      ansible/server/resize-disk.yaml 
    EOT
  }

}

#endregion
#####################################################################