# PackerMVP

A Packer configuration for building multiple VM formats from Ubuntu 22.04 with Desktop environment.

## How This Works

This repository uses Packer to build virtual machine images with Ubuntu Desktop that can be used across different virtualization platforms. Here's the approach and rationale:

### Architecture

1. **Base Image**: Starts with Ubuntu 22.04 Server cloud image (qcow2 format)
   - Cloud images are optimized, pre-installed disk images that boot quickly
   - They support cloud-init for automatic configuration (SSH keys, hostname, etc.)
   - No manual installation process required

2. **Desktop Installation**: The provisioning script installs `ubuntu-desktop-minimal`
   - Ubuntu doesn't publish official Desktop cloud images, only Server
   - Installing the desktop package on the server base is the standard approach
   - Uses the minimal variant to reduce image size while providing full desktop functionality
   - Aggressive optimizations applied to meet 2GB size limit (removes snaps, locales, unnecessary packages)

3. **Single Build, Multiple Formats**: QEMU builds the base VM once, then converts to other formats
   - More efficient than maintaining separate build configurations
   - Ensures consistency across all VM types
   - Conversion uses qemu-img (VDI for VirtualBox, VHDX for Hyper-V)

4. **Cloud-init Configuration**: Pre-configured user and SSH access
   - Creates `packer` user with password and SSH key authentication
   - SSH password authentication is disabled for security
   - Local console login enabled for desktop access

### Why These Choices?

- **Cloud images over ISO**: Faster builds, no need for autoinstall configuration, already optimized
- **Server base + Desktop install**: No official Desktop cloud images exist from Ubuntu
- **Format conversion**: Simpler maintenance than multiple Packer builders
- **4GB RAM**: Desktop environment requires more memory than minimal server

## Features

- **Multiple VM Formats**: Builds QEMU (qcow2), VirtualBox (VDI), and Hyper-V (VHDX) from a single build
- **Single Build Process**: Uses QEMU to build once, then converts to other formats
- **Cloud-init**: Pre-configured with SSH key authentication
- **Highly Optimized**: Aggressive size reduction to fit under 2GB release limit
  - Removes snap packages and snapd
  - Purges unnecessary locales (keeps only en_US.UTF-8)
  - Removes old kernels
  - Removes unnecessary applications (games, LibreOffice, Thunderbird, etc.)
  - Zeros free space for better compression

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
2. Install Ubuntu Desktop environment during provisioning
3. Apply aggressive optimizations to reduce image size below 2GB
4. Convert the qcow2 output to VDI and VHDX formats
5. Compress all formats into separate tar.gz files in the `dist/` directory

### GitHub Actions Workflow

Trigger the workflow manually from the Actions tab. The workflow will:
1. Build all VM types in a single job
2. Upload all VM formats as artifacts
3. Create a release with all VM images

## VM Configuration

All VMs are configured with:
- **OS**: Ubuntu 22.04 LTS (Desktop)
- **User**: `packer`
- **Local Login**: Username `packer`, password `packer` (change after first login)
- **SSH Authentication**: SSH key only (password disabled for SSH)
- **Resources**: 4GB RAM, 2 CPUs
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
