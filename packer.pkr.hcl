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

  boot_wait = "5s"
  boot_command = [
    "<esc><wait>",
    "<esc><wait>",
    "<f6><wait>",
    "<esc><wait>",
    " autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ --- <enter>"
  ]

  ssh_username = "packer"
  ssh_password = "packer"
  ssh_timeout  = "30m"

  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
}

build {
  name    = "ubuntu-qemu"
  sources = ["source.qemu.ubuntu"]
}