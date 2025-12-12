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
- **Optimized**: Provisioning script reduces image size

## VM Types

All VM types are built from a single `packer.pkr.hcl` configuration:

- **QEMU** (qcow2): QEMU/KVM compatible format
- **VirtualBox** (VDI): Converted from qcow2 using qemu-img
- **Hyper-V** (VHDX): Converted from qcow2 using qemu-img
- **Proxmox**: Placeholder (requires Proxmox server access)

## Usage

### Customizing VM Configuration

All VM settings can be customized by editing `variables.pkrvars.hcl`:

```hcl
# VM Resource Settings
vm_memory = 4096  # Memory in MB (default: 4096 = 4GB)
vm_cpus   = 2     # Number of CPU cores

# VM Identification
vm_name      = "craigs_vm"     # Name of the VM output file
vm_hostname  = "ubuntu-qemu"   # Hostname set inside the VM

# User Account Settings
ssh_username = "packer"                      # SSH username for provisioning
ssh_password = "packer"                      # Local login password
ssh_key_file = "keys/packer_ed25519"        # SSH private key path

# Build Settings
iso_url         = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"
output_dir      = "build-output"             # Directory for build output
disk_format     = "qcow2"                    # Output disk format
headless        = true                       # Run VM without GUI during build
ssh_timeout     = "10m"                      # SSH connection timeout
```

You can create a `variables.auto.pkrvars.hcl` file for custom configurations that will be automatically loaded by Packer.

### Building Locally

Build all VM formats at once:
```bash
packer init packer.pkr.hcl
packer build -var-file="variables.pkrvars.hcl" packer.pkr.hcl
```

This will:
1. Build the base VM using QEMU from Ubuntu 22.04 cloud image
2. Install Ubuntu Desktop environment during provisioning
3. Convert the qcow2 output to VDI and VHDX formats
4. Compress all formats into separate tar.gz files in the `dist/` directory

### GitHub Actions Workflow

Trigger the workflow manually from the Actions tab. The workflow will:
1. Build all VM types in a single job
2. Upload all VM formats as artifacts
3. Create a release with all VM images

## VM Configuration

Default VM configuration (customizable in `variables.pkrvars.hcl`):
- **OS**: Ubuntu 22.04 LTS (Desktop - installed via provisioning script)
- **User**: `packer` (configurable)
- **Local Login**: Username `packer`, password `packer` (configurable - change after first login)
- **SSH Authentication**: SSH key only (password disabled for SSH)
- **Resources**: 4GB RAM, 2 CPUs (configurable)
- **Hostname**: `ubuntu-qemu` (configurable)
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
