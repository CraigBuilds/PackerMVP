packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.0.0"
    }
  }
}

source "qemu" "craigs_vm" {
  iso_url      = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"
  iso_checksum = "none"

  disk_image = true
  format     = "qcow2"

  output_directory = "${path.root}/build-output"
  vm_name          = "craigs_vm"
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
}

build {
  name    = "all-vms"
  sources = ["source.qemu.craigs_vm"]

  provisioner "shell" {
    script = "provision/provision.sh"
  }

  # Convert to all formats and compress
  post-processor "shell-local" {
    inline = [
      "mkdir -p ${path.root}/dist",
      # QEMU qcow2 format
      "cp ${path.root}/build-output/craigs_vm ${path.root}/dist/craigs_vm_qemu.qcow2",
      "tar -czf ${path.root}/dist/craigs_vm_qemu.tar.gz -C ${path.root}/dist craigs_vm_qemu.qcow2",
      # VirtualBox VDI format
      "qemu-img convert -f qcow2 -O vdi ${path.root}/build-output/craigs_vm ${path.root}/dist/craigs_vm_virtualbox.vdi",
      "tar -czf ${path.root}/dist/craigs_vm_virtualbox.tar.gz -C ${path.root}/dist craigs_vm_virtualbox.vdi",
      # Hyper-V VHDX format
      "qemu-img convert -f qcow2 -O vhdx ${path.root}/build-output/craigs_vm ${path.root}/dist/craigs_vm_hyperv.vhdx",
      "tar -czf ${path.root}/dist/craigs_vm_hyperv.tar.gz -C ${path.root}/dist craigs_vm_hyperv.vhdx",
      # Clean up intermediate files
      "rm -f ${path.root}/dist/*.qcow2 ${path.root}/dist/*.vdi ${path.root}/dist/*.vhdx"
    ]
  }
}
