#!/bin/bash

########################################################################
### Auth: Alphakaps
### Date: 11/17/2025
### Description: This script is used for Kubernetes cluster installation
########################################################################

echo -e "Adding Kubernetes repository"
sudo apt install -y apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update

echo -e "Installation of kubelet kubeadm kubectl"
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet


# Only for Control Plane
echo -e "Control Plane Configuration and Installation of Flannel"

sudo kubeadm init --apiserver-advertise-address=192.168.2.16 --node-name $HOSTNAME --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Flanel Installation
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

joinNode=$(kubeadm token create --print-join-command)
echo "sudo $joinNode" > $HOME/join.sh
chmod +x $HOME/join.sh
