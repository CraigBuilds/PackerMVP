packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.0.0"
    }
  }
}

source "qemu" "desktop" {
  # Use the base QCOW2 as input
  iso_url      = "${path.root}/build-output-base/craigs_vm_server"
  iso_checksum = "none"

  disk_image = true
  format     = "qcow2"

  output_directory = "${path.root}/build-output-desktop"
  vm_name          = "craigs_vm_desktop"
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
  name    = "desktop"
  sources = ["source.qemu.desktop"]

  provisioner "shell" {
    script = "provision/provision-desktop.sh"
  }
}
