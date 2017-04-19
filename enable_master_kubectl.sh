#!/bin/bash

mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/ && sudo chown $(id -u):$(id -g) $HOME/.kube/admin.conf
export KUBECONFIG=$HOME/.kube/admin.conf
sed -i '/KUBECONFIG/d' ~/.bashrc
echo -e "\nexport KUBECONFIG=$HOME/.kube/admin.conf" >> ~/.bashrc
