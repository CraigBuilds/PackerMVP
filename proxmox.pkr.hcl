packer {
  required_plugins {
    proxmox = {
      source  = "github.com/hashicorp/proxmox"
      version = ">= 1.0.0"
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

variable "proxmox_insecure_skip_tls_verify" {
  type        = bool
  default     = true
  description = "Skip TLS certificate verification. Set to false for production environments with valid certificates."
}

source "proxmox-iso" "craigs_vm" {
  proxmox_url              = "${var.proxmox_url}"
  username                 = "${var.proxmox_username}"
  password                 = "${var.proxmox_password}"
  node                     = "${var.proxmox_node}"
  insecure_skip_tls_verify = var.proxmox_insecure_skip_tls_verify

  iso_url          = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"
  iso_checksum     = "none"
  iso_storage_pool = "local"

  vm_name = "craigs_vm_proxmox"

  memory = 2048
  cores  = 2

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  disks {
    type         = "scsi"
    disk_size    = "20G"
    storage_pool = "local-lvm"
    format       = "qcow2"
  }

  additional_iso_files {
    cd_files = [
      "cloud_init/user-data",
      "cloud_init/meta-data",
    ]
    cd_label         = "cidata"
    iso_storage_pool = "local"
    unmount          = true
  }

  ssh_username         = "packer"
  ssh_private_key_file = "keys/packer_ed25519"
  ssh_timeout          = "10m"

  template_name        = "craigs_vm_proxmox"
  template_description = "Ubuntu 22.04 VM built with Packer"
}

build {
  name    = "proxmox-vm"
  sources = ["source.proxmox-iso.craigs_vm"]

  provisioner "shell" {
    script = "provision/provision.sh"
  }
}
