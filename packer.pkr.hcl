packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.0.0"
    }
  }
}

source "qemu" "ubuntu_cloud" {
  # Ubuntu 22.04 cloud image (disk image)
  iso_url      = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"
  iso_checksum = "none"

  disk_image = true
  format     = "qcow2"

  output_directory = "output"
  vm_name          = "ubuntu-cloud"
  headless         = true

  memory = 1024
  cpus   = 1

  # cloud-init seed ISO
  cd_files = [
    "http/user-data",
    "http/meta-data",
  ]
  cd_label = "cidata"

  ssh_username         = "packer"
  ssh_private_key_file = "keys/packer_ed25519"
  ssh_timeout          = "10m"

  shutdown_command = "sudo shutdown -P now"
}

build {
  name    = "ubuntu-cloud"
  sources = ["source.qemu.ubuntu_cloud"]
}