# PackerMVP

## Todo

- Add a body to the release
  - It should explain what it is, how to use it, and the changes since the last release. Use a premade action if possible.
- Reduce artifact size
- Also build a proxmox, hyper-v, and a virtual box VM, alongside the qemu one
  - Make sure they all are built in the same way
  - Reduce config duplication
  - The workflow should build them in parallel 
- Add more things to the provisioning step
- Investigate implications of using a cloud image instead of an ISO with autoinstall. Maybe add an iso demo?
- Make new keys and move private key to secret
- Cache things in the CI for speed
