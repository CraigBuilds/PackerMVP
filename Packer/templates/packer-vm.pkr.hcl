packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.0.0"
    }
  }
}

variable "iso_url" {
  type        = string
  description = "URL or path to the base image (cloud image or existing QCOW2)"
}

variable "output_directory" {
  type        = string
  description = "Directory where the build output will be stored"
}

variable "vm_name" {
  type        = string
  description = "Name of the VM output file"
}

variable "provision_script" {
  type        = string
  description = "Path to the provisioning script to run"
}

variable "build_name" {
  type        = string
  description = "Name for this build"
  default     = "vm-build"
}

source "qemu" "vm" {
  iso_url      = var.iso_url
  iso_checksum = "none"

  disk_image = true
  format     = "qcow2"

  output_directory = var.output_directory
  vm_name          = var.vm_name
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
  name    = var.build_name
  sources = ["source.qemu.vm"]

  provisioner "shell" {
    script = var.provision_script
  }
}
