source "qemu" "ubuntu" {
  iso_url      = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
  iso_checksum = "none"

  output_directory = "output"
  vm_name          = "ubuntu-qemu"
  format           = "qcow2"

  headless  = true
  memory    = 1024
  cpus      = 1
  disk_size = "10G"

  http_directory = "http"

  boot_wait = "5s"
  boot_command = [
    "<esc><wait>",
    "<esc><wait>",
    "<f6><wait>",
    "<esc><wait>",
    # note the added debug + console=ttyS0 at the end:
    " autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ debug console=ttyS0 --- <enter>"
  ]

  ssh_username = "packer"
  ssh_password = "packer"
  ssh_timeout  = "30m"

  # NEW: forward guest serial to stdout; Packer will log this with PACKER_LOG=1
  qemuargs = [
    ["-serial", "stdio"]
  ]

  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
}

build {
  name    = "ubuntu-qemu"
  sources = ["source.qemu.ubuntu"]
}