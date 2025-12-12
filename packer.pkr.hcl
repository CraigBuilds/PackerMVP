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
  ssh_timeout          = "20m"

  shutdown_command = "sudo shutdown -P now"
}

source "virtualbox-iso" "ubuntu_cloud" {
  iso_url      = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
  iso_checksum = "sha256:9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"

  guest_os_type = "Ubuntu_64"
  format        = "ova"

  output_directory = "output-virtualbox"
  vm_name          = "craigs_vm"
  headless         = true

  memory = 1024
  cpus   = 1

  boot_wait = "5s"
  boot_command = [
    "<esc><wait>",
    "autoinstall ds=nocloud;",
    "<enter>"
  ]

  cd_files = [
    "cloud_init/user-data",
    "cloud_init/meta-data",
  ]
  cd_label = "cidata"

  ssh_username         = "packer"
  ssh_private_key_file = "keys/packer_ed25519"
  ssh_timeout          = "20m"

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