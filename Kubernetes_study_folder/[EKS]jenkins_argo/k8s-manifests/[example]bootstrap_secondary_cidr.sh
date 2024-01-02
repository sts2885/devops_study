
#!/bin/bash -xe

#awscli 설치 (terraform으로 .aws폴더 올려둠.)
#eks 연결
#kubectl client 설치
#secondary cidr로 노드 배포, 이후 primary cidr의 노드는 지워야 함.
#alb controller 설치

#보낸 파일
#1. .aws/credentials, config
#2. k8s-manifests/eni-configs #secondary cidr를 쓰기 위한 설정

# /var/log/user-data.log 에 로그 남기기 맨위에 -xe 꼭 붙어있어야 함.
sudo exec > >(sudo tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo BEGIN


echo "install docker first"
apt update
apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository --yes "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt update

apt install -y docker-ce docker-ce-cli containerd.io

systemctl start docker





#aws cli 설치
sudo apt update
sudo apt install -y awscli 

#eks 설정 파일 연결(aws cli 설정이 있어야 함 .aws)
aws eks --region us-east-1 update-kubeconfig --name eks-cluster

#kubectl client 설치
curl -LO https://dl.k8s.io/release/v1.23.6/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
export PATH=$PATH:/usr/local/bin/
kubectl version


#node => secondary subnet에 배치시키기
#node 숫자 변동은 설치 다 하고 마지막에 terraform 변동만 하면 됨
kubectl create -f ./k8s-manifests/eni-configs/.
kubectl set env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true
kubectl set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=failure-domain.beta.kubernetes.io/zone



echo "kubernetes_ready"