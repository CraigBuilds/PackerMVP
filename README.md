# PackerMVP

A Packer configuration for building multiple VM formats from Ubuntu 22.04 cloud images.

## Features

- **Multiple VM Formats**: Builds QEMU (qcow2), VirtualBox (VDI), and Hyper-V (VHDX) from a single build
- **Single Build Process**: Uses QEMU to build once, then converts to other formats
- **Cloud-init**: Pre-configured with SSH key authentication
- **Optimized**: Provisioning script reduces image size

## VM Types

All VM types are built from a single `packer.pkr.hcl` configuration:

- **QEMU** (qcow2): QEMU/KVM compatible format
- **VirtualBox** (VDI): Converted from qcow2 using qemu-img
- **Hyper-V** (VHDX): Converted from qcow2 using qemu-img
- **Proxmox**: Placeholder (requires Proxmox server access)

## Usage

### Building Locally

Build all VM formats at once:
```bash
packer init packer.pkr.hcl
packer build packer.pkr.hcl
```

This will:
1. Build the base VM using QEMU from Ubuntu 22.04 cloud image
2. Provision the VM with the provisioning script
3. Convert the qcow2 output to VDI and VHDX formats
4. Compress all formats into separate tar.gz files in the `dist/` directory

### GitHub Actions Workflow

Trigger the workflow manually from the Actions tab. The workflow will:
1. Build all VM types in a single job
2. Upload all VM formats as artifacts
3. Create a release with all VM images

## VM Configuration

All VMs are configured with:
- **OS**: Ubuntu 22.04 LTS (cloud image)
- **User**: `packer`
- **Local Login**: Username `packer`, password `packer` (change after first login)
- **SSH Authentication**: SSH key only (password disabled for SSH)
- **Resources**: 2GB RAM, 2 CPUs
- **SSH Public Key**: See `keys/packer_ed25519.pub`

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
