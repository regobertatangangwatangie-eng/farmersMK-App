#!/bin/bash

echo "Checking k3s..."
sudo systemctl restart k3s

echo "Checking if port 6443 is open..."
sudo ss -tulnp | grep 6443

echo "Fixing kubeconfig..."
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
sudo sed -i "s|127.0.0.1|$PUBLIC_IP|g" /etc/rancher/k3s/k3s.yaml

echo "Testing API locally..."
curl -k https://localhost:6443
