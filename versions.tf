terraform {
  required_version = "~> 1.3.7"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9.13"
    }
  }
}
