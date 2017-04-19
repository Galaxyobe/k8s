#!/bin/bash

mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/kubelet.conf $HOME/.kube/ && sudo chown $(id -u):$(id -g) $HOME/.kube/kubelet.conf
export KUBECONFIG=$HOME/.kube/kubelet.conf
sed -i '/KUBECONFIG/d' ~/.bashrc
echo -e "\nexport KUBECONFIG=$HOME/.kube/kubelet.conf" >> ~/.bashrc
