resource "proxmox_virtual_environment_vm" "vm" {
  depends_on = [
    terraform_data.ci_user_file,
    terraform_data.ci_network_file
  ]

  name  = var.name
  vm_id = var.vmid

  node_name = var.target_node

  scsi_hardware = var.scsi_hardware

  started = var.started
  on_boot = var.on_boot

  tags = sort(var.tags) # Proxmox sorts tags lexicographically

  agent {
    enabled = true
    timeout = "15m"
    trim    = true
  }

  operating_system {
    type = var.qemu_os
  }

  dynamic "clone" {
    for_each = var.template_id != null ? [var.template_id] : []

    content {
      vm_id   = clone.value
      retries = 2
      full    = true
    }
  }

  // Resources

  cpu {
    type    = var.cpu
    sockets = 1
    cores   = var.cores
  }

  memory {
    dedicated = var.memory
    floating  = var.balloon
  }

  dynamic "disk" {
    for_each = var.disk

    content {
      datastore_id = disk.value.location
      interface    = disk.value.interface
      iothread     = disk.value.iothread
      discard      = disk.value.discard
      size         = disk.value.size
    }
  }

  dynamic "network_device" {
    for_each = var.network

    content {
      bridge      = network_device.value.bridge
      vlan_id     = network_device.value.vlan_tag
      mac_address = network_device.value.mac
    }
  }

  // Cloud init

  initialization {
    // Cloud-init ISO
    datastore_id = var.ci_cdrom_storage
    interface    = "ide2"

    user_data_file_id = "${local.ci_file_storage}:${local.ci_file_relative_path_user}"
  }

  serial_device {
    device = "socket"
  }

  vga {
    type = "serial0"
  }
}
