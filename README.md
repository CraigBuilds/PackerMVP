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

### Customizing VM Configuration

All VM settings can be customized by editing `variables.pkrvars.hcl`:

```hcl
# VM Resource Settings
vm_memory = 2048  # Memory in MB (default: 2048 = 2GB)
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
2. Provision the VM with the provisioning script
3. Convert the qcow2 output to VDI and VHDX formats
4. Compress all formats into separate tar.gz files in the `dist/` directory

### GitHub Actions Workflow

Trigger the workflow manually from the Actions tab. The workflow will:
1. Build all VM types in a single job
2. Upload all VM formats as artifacts
3. Create a release with all VM images

## VM Configuration

Default VM configuration (customizable in `variables.pkrvars.hcl`):
- **OS**: Ubuntu 22.04 LTS (cloud image)
- **User**: `packer` (configurable)
- **Local Login**: Username `packer`, password `packer` (configurable - change after first login)
- **SSH Authentication**: SSH key only (password disabled for SSH)
- **Resources**: 2GB RAM, 2 CPUs (configurable)
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
