#!/bin/bash -xe

#awscli 설치 (terraform으로 .aws폴더 올려둠.)
#eks 연결
#kubectl client 설치
#secondary cidr로 노드 배포, 이후 primary cidr의 노드는 지워야 함.
#alb controller 설치

# /var/log/user-data.log 에 로그 남기기 맨위에 -xe 꼭 붙어있어야 함.
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo BEGIN


#보낼 폴더 목록 정리
#- .aws
#- k8s-manifests

#aws cli 설치
sudo apt update
sudo apt install -y awscli 

#eks 설정 파일 연결(aws cli 설정이 있어야 함 .aws)
aws eks --region us-east-1 update-kubeconfig --name eks-cluster

#kubectl client 설치
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.7/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
export PATH=$PATH:/usr/local/bin/
kubectl version


#node => secondary subnet에 배치시키기
#node 숫자 변동은 설치 다 하고 마지막에 terraform 변동만 하면 됨
#보낼파일 ./k8s-manifests 폴더 전체
kubectl create -f ./k8s-manifests/eni-configs/.
kubectl set env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true
kubectl set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=failure-domain.beta.kubernetes.io/zone



#이거 테라폼 파일 보내기 알고 나서 갑자기 급물살 탄다.

##alb controller 설치
#eksctl
curl --location \
"https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin

eksctl version

eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=eks-cluster --approve

#222170749288
#iam 들어가서 arn 찾아 놔야 함
eksctl create iamserviceaccount \
--cluster=eks-cluster \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::222170749288:policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--approve


#아직 추가할거 많음.




echo "kubernetes_ready"