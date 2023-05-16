#!/bin/bash -xe

# /var/log/user-data.log 에 로그 남기기 맨위에 -xe 꼭 붙어있어야 함.
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo BEGIN
# disable swap
swapoff -a

#kubernetes version이랑 node 체크 적을것

# install docker
# terraform으로 몇번 자동생성 하니까 docker 설치를 실패하는 케이스가
apt update
apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository --yes "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt update

apt install -y docker-ce docker-ce-cli containerd.io

systemctl start docker

apt-get update

# install kubernetes
# https://medium.com/finda-tech/overview-8d169b2a54ff
# https://mlops-for-all.github.io/docs/setup-kubernetes/kubernetes-with-kubeadm/
# 위 두 링크 합쳐서 썼음
# Malformed entry 1 in list file /etc/apt/sources.list.d/kubernetes.list (URI parse)
# 이 에러가 떠서...
# source.list 추가가 모두의 MLOps에는 없었음.

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get install -y apt-transport-https ca-certificates curl &&
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg &&
#이 부분에 오타가 있었던 모양
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list &&
sudo apt-get update
sudo apt-get install -y kubelet=1.21.7-00 kubeadm=1.21.7-00 kubectl=1.21.7-00 &&
sudo apt-mark hold kubelet kubeadm kubectl

#apt-get install -y apt-transport-https ca-certificates curl &&
#curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg &&
#echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] Index of /apt//  kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list &&
#apt-get update
#apt-get install -y kubelet=1.21.7-00 kubeadm=1.21.7-00 kubectl=1.21.7-00 &&
#apt-mark hold kubelet kubeadm kubectl

kubeadm version

kubelet --version

kubectl version

modprobe br_netfilter
sysctl -p /etc/sysctl.conf
sysctl net.bridge.bridge-nf-call-iptables=1

echo 1 > /proc/sys/net/ipv4/ip_forward

kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.1.0.28

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

kubectl get nodes

kubectl get pod --namespace=kube-system -o wide

echo END
