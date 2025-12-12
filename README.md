# PackerMVP

A Packer configuration for building multiple VM formats from Ubuntu 22.04 cloud images.

## Features

- **Two-Stage Build Process**: 
  - Stage 1: Server base image (minimal, no desktop)
  - Stage 2: Desktop image derived from base with XFCE desktop environment
- **Multiple VM Formats**: Builds QEMU (qcow2), VirtualBox (VDI), and Hyper-V (VHDX) from a single build
- **Cloud-init**: Pre-configured with SSH key authentication
- **Optimized**: Provisioning scripts reduce image size

## VM Types

VM images are built using a two-stage process from Packer configurations:

### Stage 1: Server Base (`packer-base.pkr.hcl`)
Minimal Ubuntu 22.04 server installation without desktop environment.

### Stage 2: Desktop (`packer-desktop.pkr.hcl`)
Derived from the server base image, adds XFCE desktop environment.

Both stages produce:
- **QEMU** (qcow2): QEMU/KVM compatible format
- **VirtualBox** (VDI): Converted from qcow2 using qemu-img
- **Hyper-V** (VHDX): Converted from qcow2 using qemu-img
- **Proxmox**: qcow2 format for Proxmox VE

## Usage

### Building Locally

#### Build Server Base Only
```bash
packer init packer-base.pkr.hcl
packer build packer-base.pkr.hcl
```

This builds the minimal server image to `build-output-base/craigs_vm_server`.

#### Build Desktop (requires base to be built first)
```bash
packer init packer-desktop.pkr.hcl
packer build packer-desktop.pkr.hcl
```

This builds the desktop image from the base to `build-output-desktop/craigs_vm_desktop`.

#### Build Both Stages
```bash
# Build base first
packer init packer-base.pkr.hcl
packer build packer-base.pkr.hcl

# Then build desktop
packer init packer-desktop.pkr.hcl
packer build packer-desktop.pkr.hcl
```

#### Legacy Single Build (deprecated)
The original `packer.pkr.hcl` is still available but will be removed in a future version:
```bash
packer init packer.pkr.hcl
packer build packer.pkr.hcl
```

### GitHub Actions Workflow

Trigger the workflow manually from the Actions tab. The workflow will:
1. Build the server base VM (Stage 1)
2. Build the desktop VM from the base (Stage 2)
3. Convert both to all supported VM formats (QEMU, VirtualBox, Hyper-V, Proxmox)
4. Upload all VM formats as artifacts
5. Create a release with all VM images

## VM Configuration

### Server Base Image
- **OS**: Ubuntu 22.04 LTS (cloud image)
- **Type**: Minimal server installation
- **User**: `packer`
- **Local Login**: Username `packer`, password `packer` (change after first login)
- **SSH Authentication**: SSH key only (password disabled for SSH)
- **Resources**: 2GB RAM, 2 CPUs
- **SSH Public Key**: See `keys/packer_ed25519.pub`

### Desktop Image
Includes everything from Server Base, plus:
- **Desktop Environment**: XFCE (lightweight)
- **Display Manager**: LightDM
- **Browser**: Firefox
- **Additional**: XFCE goodies and utilities

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
