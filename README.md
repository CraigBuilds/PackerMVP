# PackerMVP

A Packer configuration for building multiple VM formats from Ubuntu 22.04 cloud images.

## Features

- **Three-Stage Build Process**: 
  - Stage 1: Base - Cloud image with minimal configuration
  - Stage 2: Desktop - Adds XFCE desktop environment
  - Stage 3: Optimize - Size reduction and compression optimization
- **Multiple VM Formats**: Builds QEMU (qcow2), VirtualBox (VDI), and Hyper-V (VHDX) from a single build
- **Cloud-init**: Pre-configured with SSH key authentication
- **Optimized**: Provisioning scripts reduce image size below 2GB

## VM Types

VM images are built using a three-stage process from Packer configurations:

### Stage 1: Base (`Packer/templates/packer-base.pkr.hcl`)
Minimal Ubuntu 22.04 cloud image with basic configuration only.

### Stage 2: Desktop (`Packer/templates/packer-desktop.pkr.hcl`)
Derived from the base image, adds minimal XFCE desktop environment.

### Stage 3: Optimize (`Packer/templates/packer-optimize.pkr.hcl`)
Derived from the desktop image, applies size optimizations and compression improvements.

Final optimized image produces:
- **QEMU** (qcow2): QEMU/KVM compatible format
- **VirtualBox** (VDI): Converted from qcow2 using qemu-img
- **Hyper-V** (VHDX): Converted from qcow2 using qemu-img
- **Proxmox**: qcow2 format for Proxmox VE

## Usage

### Building Locally

#### Build All Stages
```bash
# Stage 1: Base
packer init Packer/templates/packer-base.pkr.hcl
packer build Packer/templates/packer-base.pkr.hcl

# Stage 2: Desktop
packer init Packer/templates/packer-desktop.pkr.hcl
packer build Packer/templates/packer-desktop.pkr.hcl

# Stage 3: Optimize
packer init Packer/templates/packer-optimize.pkr.hcl
packer build Packer/templates/packer-optimize.pkr.hcl
```

This builds the complete VM to `build-output-optimize/craigs_vm`.

### GitHub Actions Workflow

Trigger the workflow manually from the Actions tab. The workflow will:
1. Build the base VM (Stage 1)
2. Build the desktop VM from the base (Stage 2)
3. Optimize the desktop VM (Stage 3)
4. Convert the optimized VM to all supported formats (QEMU, VirtualBox, Hyper-V, Proxmox)
5. Upload all VM formats as artifacts
6. Create a release with all VM images

## VM Configuration

### Base Image
- **OS**: Ubuntu 22.04 LTS (cloud image)
- **Type**: Minimal cloud image with basic configuration
- **User**: `packer`
- **Local Login**: Username `packer`, password `packer` (change after first login)
- **SSH Authentication**: SSH key only (password disabled for SSH)
- **Resources**: 2GB RAM, 2 CPUs
- **SSH Public Key**: See `Packer/keys/packer_ed25519.pub`

### Desktop Image
Includes everything from Base, plus:
- **Desktop Environment**: XFCE (minimal, lightweight)
- **Display Manager**: LightDM

### Optimized Image
Includes everything from Desktop, with:
- Size-reduced through aggressive cleanup and compression
- Ready for artifact upload (< 2GB)

## Todo

- [x] Add a body to the release
- [x] Build multiple VM formats (QEMU, VirtualBox, Hyper-V)
- [x] Reduce config duplication
- [ ] Further reduce artifact size?
- [ ] Add more things to the provisioning step
- [ ] Investigate implications of using a cloud image instead of an ISO with autoinstall
- [ ] Use a smaller OS than Ubuntu?
- [ ] Make new keys and move private key to secret
- [ ] Cache things in the CI for speed
