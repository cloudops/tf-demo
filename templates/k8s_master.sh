#!/usr/bin/env bash

## master node on centos 7.4

## SPECS
# CentOS 7.4
# Kernel: 3.10.0-862.14.4
# CPU: 8 vCPU
# RAM: 32GB
# Root Drive: 60GB

## CLI ARGS AND VAR INIT
if [ -z "$1" ]
then
      echo "Missing 'master' private IP as first argument..."
      exit 1
fi

if [ -z "$2" ]
then
      echo "Missing 'pod' network CIDR..."
      exit 1
fi

if [ -z "$3" ]
then
      echo "Missing 'service' network CIDR..."
      exit 1
fi

TOKEN=""
if [ -n "$4" ]
then
      TOKEN="--token $4"
fi

echo "Setting up K8S Master with token: $TOKEN"

K8S_MASTER_IP=$1
POD_CIDR=$2
SERVICE_CIDR=$3

## SETUP PACKAGES AND SERVICES
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

sudo yum install -y git

sudo yum install -y ntp ntpdate
sudo ntpdate pool.ntp.org
sudo systemctl enable ntpd && sudo systemctl start ntpd

sudo yum install -y docker
sudo systemctl enable docker.service
sudo service docker start

sudo yum install -y kubelet kubeadm kubectl

## disable the default CNI
sudo sed -i 's|Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"|#Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"|g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo systemctl daemon-reload
sudo service kubelet restart

sudo systemctl enable kubelet && sudo systemctl start kubelet

sudo sysctl -w net.bridge.bridge-nf-call-iptables=1
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# convenience aliases
echo "alias k='kubectl'" >> $HOME/.bash_profile
echo "alias ks='kubectl -n kube-system'" >> $HOME/.bash_profile

sleep 5

## INSTALL KUBERNETES
sudo kubeadm init --apiserver-cert-extra-sans $K8S_MASTER_IP $TOKEN --pod-network-cidr ${POD_CIDR} --service-cidr ${SERVICE_CIDR} >> $HOME/kubeadm_init.log

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $USER:$USER $HOME/.kube/config

# ## INSTALL TUNGSTEN FABRIC
sudo mkdir -pm 777 /var/lib/contrail/kafka-logs
kubectl apply -f tf.yaml
