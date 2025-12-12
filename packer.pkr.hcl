packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.0.0"
    }
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = ">= 1.0.0"
    }
  }
}

source "qemu" "ubuntu_cloud" {
  iso_url      = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"
  iso_checksum = "none"

  disk_image = true
  format     = "qcow2"

  output_directory = "output"
  vm_name          = "craigs_vm"
  headless         = true

  memory = 1024
  cpus   = 1

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

source "virtualbox-iso" "ubuntu_cloud" {
  iso_url      = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"
  iso_checksum = "none"

  guest_os_type = "Ubuntu_64"
  format        = "ova"

  output_directory = "output-virtualbox"
  vm_name          = "craigs_vm"
  headless         = true

  memory = 1024
  cpus   = 1

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
  name    = "ubuntu-cloud"
  sources = [
    "source.qemu.ubuntu_cloud",
    "source.virtualbox-iso.ubuntu_cloud"
  ]

  provisioner "shell" {
    script = "provision/provision.sh"
  }
}