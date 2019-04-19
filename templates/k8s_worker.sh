#!/usr/bin/env bash

## worker node on centos 7.4

## SPECS
# CentOS 7.4
# Kernel: 3.10.0-862.14.4
# CPU: 8 vCPU
# RAM: 16GB
# Root Drive: 40GB

if [ -z "$1" ]
then
      echo "Missing 'master' private IP as first argument..."
      exit 1
fi

if [ -z "$2" ]
then
      echo "Missing Kubernetes join 'token'..."
      exit 1
fi

echo "Setting up K8S Worker with token: $2"

K8S_MASTER_IP=$1
TOKEN=$2

swapoff -a
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config

sudo bash -c 'cat > /etc/yum.repos.d/kubernetes.repo' << EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

## just in case your template is ancient
#sudo yum update -y

sudo yum install -y ntp ntpdate
sudo ntpdate pool.ntp.org
sudo systemctl enable ntpd && sudo systemctl start ntpd

sudo yum install -y docker
sudo systemctl enable docker.service
sudo service docker start

sudo yum install -y kubelet kubeadm kubectl
sudo systemctl enable kubelet && sudo systemctl start kubelet

sudo sysctl -w net.bridge.bridge-nf-call-iptables=1
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# convenience aliases
echo "alias k='kubectl'" >> $HOME/.bash_profile
echo "alias ks='kubectl -n kube-system'" >> $HOME/.bash_profile

sudo kubeadm join --token $TOKEN $K8S_MASTER_IP:6443 --discovery-token-unsafe-skip-ca-verification >> $HOME/kubeadm_join.log