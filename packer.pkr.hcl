packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.0.0"
    }
  }
}

source "qemu" "ubuntu" {
  iso_url      = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
  iso_checksum = "none"

  output_directory = "output"
  vm_name          = "ubuntu-qemu"
  format           = "qcow2"

  headless  = true
  memory    = 2048
  cpus      = 2
  disk_size = "10G"

  http_directory = "http"
  boot_wait      = "8s"

  # Ubuntu 22.04 live-server ISO autoinstall via GRUB cmdline.
  # IMPORTANT: escape the ';' in ds=... with \;
  boot_command = [
    "c", "<wait>",
    "linux /casper/vmlinuz --- autoinstall debug ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]

  ssh_username         = "packer"
  ssh_private_key_file = "keys/packer_ed25519"
  ssh_timeout          = "40m"

  shutdown_command = "sudo shutdown -P now"
}

build {
  name    = "ubuntu-qemu"
  sources = ["source.qemu.ubuntu"]
}