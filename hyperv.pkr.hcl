packer {
  required_plugins {
    hyperv = {
      source  = "github.com/hashicorp/hyperv"
      version = ">= 1.0.0"
    }
  }
}

source "hyperv-iso" "craigs_vm" {
  iso_url              = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"
  iso_checksum         = "none"
  iso_target_extension = "img"

  output_directory   = "${path.root}/build-output-hyperv"
  vm_name            = "craigs_vm_hyperv"
  memory             = 2048
  cpus               = 2
  generation         = 2
  switch_name        = "Default Switch"
  enable_secure_boot = false

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
  name    = "hyperv-vm"
  sources = ["source.hyperv-iso.craigs_vm"]

  provisioner "shell" {
    script = "provision/provision.sh"
  }

  post-processor "compress" {
    output            = "${path.root}/dist/craigs_vm_hyperv.tar.gz"
    compression_level = 6
  }
}
