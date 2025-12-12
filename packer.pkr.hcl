# Variable Definitions
# Override these values by editing variables.pkrvars.hcl

variable "vm_memory" {
  type        = number
  description = "Memory allocation in MB"
  default     = 4096
}

variable "vm_cpus" {
  type        = number
  description = "Number of CPU cores"
  default     = 2
}

variable "vm_name" {
  type        = string
  description = "Name of the output VM file"
  default     = "craigs_vm"
}

variable "vm_hostname" {
  type        = string
  description = "Hostname for the VM"
  default     = "ubuntu-qemu"
}

variable "ssh_username" {
  type        = string
  description = "SSH username for provisioning"
  default     = "packer"
}

variable "ssh_password" {
  type        = string
  description = "Local login password (for documentation - actual hash in user-data template)"
  default     = "packer"
}

variable "ssh_key_file" {
  type        = string
  description = "Path to SSH private key for provisioning"
  default     = "keys/packer_ed25519"
}

variable "iso_url" {
  type        = string
  description = "URL to the base OS image"
  default     = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"
}

variable "output_dir" {
  type        = string
  description = "Directory for build output"
  default     = "build-output"
}

variable "disk_format" {
  type        = string
  description = "Output disk format"
  default     = "qcow2"
}

variable "headless" {
  type        = bool
  description = "Run VM without GUI during build"
  default     = true
}

variable "ssh_timeout" {
  type        = string
  description = "SSH connection timeout"
  default     = "10m"
}

variable "install_desktop" {
  type        = bool
  description = "Install Ubuntu Desktop environment"
  default     = true
}

variable "aggressive_cleanup" {
  type        = bool
  description = "Perform aggressive cleanup to reduce image size (removes snaps, locales, etc.)"
  default     = true
}

packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.0.0"
    }
  }
}

source "qemu" "craigs_vm" {
  iso_url      = var.iso_url
  iso_checksum = "none"

  disk_image = true
  format     = var.disk_format

  output_directory = "${path.root}/${var.output_dir}"
  vm_name          = var.vm_name
  headless         = var.headless

  memory = var.vm_memory
  cpus   = var.vm_cpus

  cd_content = {
    "meta-data" = templatefile("${path.root}/cloud_init/meta-data.pkrtpl.hcl", {
      vm_hostname = var.vm_hostname
    })
    "user-data" = templatefile("${path.root}/cloud_init/user-data.pkrtpl.hcl", {
      ssh_username = var.ssh_username
      ssh_password = var.ssh_password
    })
  }
  cd_label = "cidata"

  ssh_username         = var.ssh_username
  ssh_private_key_file = var.ssh_key_file
  ssh_timeout          = var.ssh_timeout

  shutdown_command = "sudo shutdown -P now"
}

build {
  name    = "base-vm"
  sources = ["source.qemu.craigs_vm"]

  provisioner "shell" {
    script = "provision/provision.sh"
    environment_vars = [
      "VM_NAME=${var.vm_name}",
      "VM_HOSTNAME=${var.vm_hostname}",
      "SSH_USERNAME=${var.ssh_username}",
      "INSTALL_DESKTOP=${var.install_desktop}",
      "AGGRESSIVE_CLEANUP=${var.aggressive_cleanup}",
    ]
  }
}
