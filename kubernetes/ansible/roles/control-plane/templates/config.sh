#!/bin/bash

########################################################################
### Auth: Alphakaps
### Date: 11/17/2025
### Description: This script is used for Kubernetes cluster installation
########################################################################

echo -e "Refreshing the list of available packages"
sudo apt update

echo -e "Desabling a swap"
sudo swapoff -a
sudo sed -i '/\/swap/ s/^/#/' /etc/fstab

echo -e "Configuration of /etc/sysctl.d/kubernetes.conf"
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

echo -e "Containerd Configuration"
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

sudo snap install helm --classic

source <(kubectl completion bash)

echo "alias k='kubectl'" >> ~/.bashrc
echo "alias kg='kubectl get'" >> ~/.bashrc
echo "alias kgp='kubectl get pods'" >> ~/.bashrc
echo "alias kgn='kubectl get nodes'" >> ~/.bashrc
echo "alias kdesc='kubectl describe'" >> ~/.bashrc
echo "alias kaf='kubectl apply -f'" >> ~/.bashrc
echo "alias kcf='kubectl create -f'" >> ~/.bashrc

source ~/.bashrc

complete -F __start_kubectl k