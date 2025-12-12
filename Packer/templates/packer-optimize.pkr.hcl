packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.0.0"
    }
  }
}

source "qemu" "optimize" {
  # Use the desktop QCOW2 as input
  iso_url      = "${path.root}/build-output-desktop/craigs_vm_desktop"
  iso_checksum = "none"

  disk_image = true
  format     = "qcow2"

  output_directory = "${path.root}/build-output-optimize"
  vm_name          = "craigs_vm"
  headless         = true

  memory = 2048
  cpus   = 2

  cd_files = [
    "Packer/cloud_init/user-data",
    "Packer/cloud_init/meta-data",
  ]
  cd_label = "cidata"

  ssh_username         = "packer"
  ssh_private_key_file = "Packer/keys/packer_ed25519"
  ssh_timeout          = "10m"

  shutdown_command = "sudo shutdown -P now"
}

build {
  name    = "optimize"
  sources = ["source.qemu.optimize"]

  provisioner "shell" {
    script = "Packer/provision/provision-optimize.sh"
  }
}
