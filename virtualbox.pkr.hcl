# VirtualBox build - converts QEMU qcow2 to VirtualBox format
# Note: VirtualBox doesn't natively support cloud disk images like QEMU does
# So we build with QEMU first, then convert to VirtualBox format

packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.0.0"
    }
  }
}

source "qemu" "craigs_vm_for_vbox" {
  iso_url      = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"
  iso_checksum = "none"

  disk_image = true
  format     = "qcow2"

  output_directory = "${path.root}/build-output-virtualbox"
  vm_name          = "craigs_vm_virtualbox"
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
  name    = "virtualbox-vm"
  sources = ["source.qemu.craigs_vm_for_vbox"]

  provisioner "shell" {
    script = "provision/provision.sh"
  }

  # Convert qcow2 to VDI format for VirtualBox
  post-processor "shell-local" {
    inline = [
      "mkdir -p ${path.root}/dist",
      "qemu-img convert -f qcow2 -O vdi ${path.root}/build-output-virtualbox/craigs_vm_virtualbox ${path.root}/dist/craigs_vm_virtualbox.vdi"
    ]
  }

  post-processor "compress" {
    output            = "${path.root}/dist/craigs_vm_virtualbox.tar.gz"
    compression_level = 6
  }
}
