# PackerMVP

A Packer configuration for building multiple VM formats from Ubuntu 22.04 cloud images.

## Features

- **Multiple VM Formats**: Builds QEMU, VirtualBox, Hyper-V, and Proxmox VMs
- **Parallel Builds**: GitHub Actions workflow builds all VM types in parallel
- **Cloud-init**: Pre-configured with SSH key authentication
- **Optimized**: Provisioning script reduces image size

## VM Types

- **QEMU** (`qemu.pkr.hcl`): QEMU/KVM compatible image in qcow2 format
- **VirtualBox** (`virtualbox.pkr.hcl`): VirtualBox OVA format
- **Hyper-V** (`hyperv.pkr.hcl`): Microsoft Hyper-V compatible image
- **Proxmox** (`proxmox.pkr.hcl`): Proxmox template (requires Proxmox server)

## Usage

### Building Locally

Build a specific VM type:
```bash
# QEMU
packer init qemu.pkr.hcl
packer build qemu.pkr.hcl

# VirtualBox
packer init virtualbox.pkr.hcl
packer build virtualbox.pkr.hcl

# Hyper-V (Windows only)
packer init hyperv.pkr.hcl
packer build hyperv.pkr.hcl

# Proxmox (requires Proxmox server access)
packer init proxmox.pkr.hcl
packer build -var="proxmox_url=https://your-proxmox:8006/api2/json" \
  -var="proxmox_username=user@pam" \
  -var="proxmox_password=password" \
  proxmox.pkr.hcl
```

### GitHub Actions Workflow

Trigger the workflow manually from the Actions tab to build all VMs in parallel. The workflow will:
1. Build each VM type on the appropriate runner
2. Upload each VM as an artifact
3. Create a release with all VM images

## VM Configuration

All VMs are configured with:
- **OS**: Ubuntu 22.04 LTS (cloud image)
- **User**: `packer`
- **Authentication**: SSH key only (password disabled)
- **Resources**: 2GB RAM, 2 CPUs
- **SSH Public Key**: See `keys/packer_ed25519.pub`

## Todo

- [x] Add a body to the release
  - [x] It should explain what it is, how to use it, and the changes since the last release
- [x] Build a proxmox, hyper-v, and a virtual box VM, alongside the qemu one
  - [x] Make sure they all are built in the same way
  - [x] Reduce config duplication
  - [x] The workflow should build them in parallel
- [ ] Further reduce artifact size?
- [ ] Add more things to the provisioning step
- [ ] Investigate implications of using a cloud image instead of an ISO with autoinstall. Maybe add an iso Ubuntu?
- [ ] Use a smaller OS than Ubuntu?
- [ ] Make new keys and move private key to secret
- [ ] Cache things in the CI for speed
