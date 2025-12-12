packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.0.0"
    }
  }
}

source "qemu" "server_base" {
  iso_url      = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"
  iso_checksum = "none"

  disk_image = true
  format     = "qcow2"

  output_directory = "${path.root}/build-output-base"
  vm_name          = "craigs_vm_server"
  headless         = true

  memory = 2048
  cpus   = 2

  cd_files = [
    "cloud_init/user-data",
    "cloud_init/meta-data",
  ]
  cd_label = "cidata"

  ssh_username         = "packer"
  ssh_private_key_file = "keys/packer_ed25519"
  ssh_timeout          = "10m"

  shutdown_command = "sudo shutdown -P now"
}

build {
  name    = "server-base"
  sources = ["source.qemu.server_base"]

  provisioner "shell" {
    script = "provision/provision.sh"
  }
}
