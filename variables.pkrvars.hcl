# VM Configuration Variables
# Customize these values to adjust VM settings when building new images

# VM Resource Settings
vm_memory = 2048  # Memory in MB (default: 2048 = 2GB)
vm_cpus   = 2     # Number of CPU cores

# VM Identification
vm_name      = "craigs_vm"     # Name of the VM output file
vm_hostname  = "ubuntu-qemu"   # Hostname set inside the VM

# User Account Settings
ssh_username = "packer"                      # SSH username for provisioning
ssh_password = "packer"                      # Local login password (change after first login)
ssh_key_file = "keys/packer_ed25519"        # SSH private key path for provisioning

# Build Settings
iso_url         = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"
output_dir      = "build-output"             # Directory for build output
disk_format     = "qcow2"                    # Output disk format (qcow2, raw, etc.)
headless        = true                       # Run VM without GUI during build
ssh_timeout     = "10m"                      # SSH connection timeout
