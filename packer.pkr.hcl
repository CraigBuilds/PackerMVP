packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.0.0"
    }
  }
}

source "qemu" "ubuntu" {
  # Ubuntu 22.04 live server ISO
  iso_url      = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
  iso_checksum = "none" # keep simple; add real checksum later if desired

  output_directory = "output"
  vm_name          = "ubuntu-qemu"
  format           = "qcow2"

  headless  = true
  memory    = 2048
  cpus      = 2
  disk_size = "10G"

  # Serve autoinstall config via HTTP from ./http
  http_directory = "http"

  # Wait briefly before typing into GRUB
  boot_wait = "5s"

  # Use GRUB command line directly for a stable autoinstall setup
  # Note: no 'quiet' flag, so you get verbose boot output.
  boot_command = [
    "c", "<wait>",
    "linux /casper/vmlinuz --- autoinstall 'ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'", "<enter><wait>",
    "initrd /casper/initrd", "<enter><wait>",
    "boot", "<enter>"
  ]

  # SSH communicator: just enough for Packer to know the install succeeded
  ssh_username = "packer"
  ssh_password = "packer"
  ssh_timeout  = "30m"

  # Let the QEMU plugin manage networking and SSH port forwarding.
  # No qemuargs overriding network.

  # Clean shutdown when Packer is done
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
}

build {
  name    = "ubuntu-qemu"
  sources = ["source.qemu.ubuntu"]
}