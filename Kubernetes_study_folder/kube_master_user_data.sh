#!/bin/bash -xe

# /var/log/user-data.log 에 로그 남기기 맨위에 -xe 꼭 붙어있어야 함.
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo BEGIN
# disable swap
swapoff -a

#kubernetes version이랑 node 체크 적을것

# install docker
# terraform으로 몇번 자동생성 하니까 docker 설치를 실패하는 케이스가있다(서버에서 설치파일이 안받아짐)
#apt update
apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository --yes "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt update

apt install -y docker-ce docker-ce-cli containerd.io

systemctl start docker

apt-get update




#install kubernetes
apt-get install -y apt-transport-https 
apt-get install -y ca-certificates 
apt-get install -y curl


#curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

#old key : deprecated warning이 나오는데 되긴 함. 나중엔 얘네가 안정되면 새 주소로 바꿔야될거임
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

#curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
#chmod 0644 /etc/apt/keyrings/kubernetes-archive-keyring.gpg
chmod 0644 /usr/share/keyrings/kubernetes-archive-keyring.gpg



apt-get update
apt-get install -y kubelet=1.21.7-00 kubeadm=1.21.7-00 kubectl=1.21.7-00
#apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

kubeadm version

kubelet --version

kubectl version --client




#network setting
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system


####master node setting

echo 1 > /proc/sys/net/ipv4/ip_forward

private_ip=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)

kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$private_ip \
| tee /var/log/kubeadm_init_print.txt
tail -n 2 /var/log/kubeadm_init_print.txt > /var/log/kubeadm_join.txt

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

kubectl get nodes

kubectl get pod --namespace=kube-system -o wide

echo "kubernetes_ready"
