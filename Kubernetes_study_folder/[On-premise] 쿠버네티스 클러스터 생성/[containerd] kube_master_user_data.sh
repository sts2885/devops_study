#!/bin/bash -xe

# /var/log/user-data.log 에 로그 남기기 맨위에 -xe 꼭 붙어있어야 함.
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo BEGIN
# disable swap
swapoff -a



#kubernetes version이랑 node 체크 적을것


#kubernetes에서 docker 지원 중단으로 containerd를 쓰게됨
#install containerd

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

sudo apt-get update 

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
    
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y containerd.io

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd



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

#처음 설치 했을때 새 키 (위쪽) 이 쟤네 서버가 문제인지 사용이 안됐었음
#github 뒤지다가 얘네가 오래전에 쓰던 키가 있다고(아래쪽) 해서 그걸로 설치하니 됐었음.
#curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
#chmod 0644 /etc/apt/keyrings/kubernetes-archive-keyring.gpg
chmod 0644 /usr/share/keyrings/kubernetes-archive-keyring.gpg



apt-get update
#apt-get install -y kubelet=1.21.7-00 kubeadm=1.21.7-00 kubectl=1.21.7-00
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

kubeadm version

kubelet --version

kubectl version --client




#network setting
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system


####master node setting

echo 1 > /proc/sys/net/ipv4/ip_forward

private_ip=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)

kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$private_ip \
| tee /var/log/kubeadm_init_print.txt
tail -n 2 /var/log/kubeadm_init_print.txt > /var/log/kubeadm_join.txt


#사이트 등에서는 이렇게 나와있는데
#유저 ubuntu 에서는 $HOME이 /home/ubuntu 이고 여기 에는 .kube/config가 무슨 폴더 링크임
#근데 여기서 추가한건 $HOME /root 근데 이 밑에는 .kube가 없음
#근데 또 /root라고 명시하니까 동작 안함

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo $HOME > /var/log/home.txt

mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown $(id -u):$(id -g) /root/.kube/config

#mkdir -p /home/ubuntu/.kube
#cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
#chown $(id -u):$(id -g) /home/ubuntu/.kube/config

#export KUBECONFIG=/etc/kubernetes/kubelet.conf
#export KUBECONFIG=/etc/kubernetes/admin.conf
#https://www.thegeekdiary.com/troubleshooting-kubectl-error-the-connection-to-the-server-x-x-x-x6443-was-refused-did-you-specify-the-right-host-or-port/
export KUBECONFIG=/root/.kube/config

#containerd 기반에 쿠버네티스 새 버전으로 설치하면서
#이 명령어가 userdata의 user로는 안돌아감
#root는 되도...
#jupyter에서 명령하는걸로 바꾸자.
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

#kubectl get nodes

#kubectl get pod --namespace=kube-system -o wide

echo "kubernetes_ready"

