#!/usr/bin/env bash
set -eux

echo 'provisioned-by-packer' | sudo tee /etc/provisioned-by-packer

sudo apt-get update
sudo apt-get install -y ca-certificates curl

sudo systemctl enable --now ssh