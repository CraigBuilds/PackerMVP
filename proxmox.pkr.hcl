packer {
  required_plugins {
    proxmox = {
      source  = "github.com/hashicorp/proxmox"
      version = ">= 1.1.0"
    }
  }
}

variable "proxmox_url" {
  type    = string
  default = ""
}

variable "proxmox_username" {
  type    = string
  default = ""
}

variable "proxmox_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "proxmox_node" {
  type    = string
  default = "pve"
}

source "proxmox-iso" "craigs_vm" {
  proxmox_url = "${var.proxmox_url}"
  username    = "${var.proxmox_username}"
  password    = "${var.proxmox_password}"
  node        = "${var.proxmox_node}"

  iso_url      = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
  iso_checksum = "sha256:9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"

  iso_storage_pool = "local"

  vm_name = "craigs_vm"
  vm_id   = 9000

  memory = 1024
  cores  = 1

  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }

  disks {
    type         = "scsi"
    disk_size    = "20G"
    storage_pool = "local-lvm"
  }

  scsi_controller = "virtio-scsi-pci"

  ssh_username         = "packer"
  ssh_private_key_file = "keys/packer_ed25519"
  ssh_timeout          = "20m"

  boot_wait = "5s"
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]

  http_directory = "cloud_init"

  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  insecure_skip_tls_verify = true
  unmount_iso              = true
}

build {
  name    = "craigs_vm-proxmox"
  sources = ["source.proxmox-iso.craigs_vm"]

  provisioner "shell" {
    script = "provision/provision.sh"
  }
}
