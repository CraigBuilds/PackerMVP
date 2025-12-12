packer {
  required_plugins {
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = ">= 1.0.0"
    }
  }
}

source "virtualbox-iso" "craigs_vm" {
  iso_url              = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"
  iso_checksum         = "none"
  iso_target_extension = "img"

  guest_os_type = "Ubuntu_64"

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

  hard_drive_interface = "sata"
  iso_interface        = "sata"
  guest_additions_mode = "disable"
  format               = "ova"
}

build {
  name    = "virtualbox-vm"
  sources = ["source.virtualbox-iso.craigs_vm"]

  provisioner "shell" {
    script = "provision/provision.sh"
  }

  post-processor "compress" {
    output            = "${path.root}/dist/craigs_vm_virtualbox.tar.gz"
    compression_level = 6
  }
}
