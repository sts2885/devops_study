#!/bin/bash -xe

#awscli 설치 (terraform으로 .aws폴더 올려둠.)
#eks 연결
#kubectl client 설치
#secondary cidr로 노드 배포, 이후 primary cidr의 노드는 지워야 함.
#alb controller 설치

#보낸 파일
#1. .aws/credentials, config
#2. k8s-manifests/eni-configs #secondary cidr를 쓰기 위한 설정인데 강사님도 가르쳐주곤 두번다신 안써서 유의미 한가 싶음.

# /var/log/user-data.log 에 로그 남기기 맨위에 -xe 꼭 붙어있어야 함.
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo BEGIN




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
#kubectl create -f ./k8s-manifests/eni-configs/.
#kubectl set env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true
#kubectl set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=failure-domain.beta.kubernetes.io/zone




##alb controller 설치
#eksctl
curl --location \
"https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin

eksctl version




#aws lb controller 설치
#https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/aws-load-balancer-controller.html


curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=eks-cluster --approve

#기존에 eksctl get iamserviceaccount를 통해 기존버전이 있으면 지우고 생성
#eksctl delete iamserviceaccount \
#--cluster=eks-cluster \
#--namespace=kube-system \
#--name=aws-load-balancer-controller

#iam 들어가서 arn 찾아 놔야 함
eksctl create iamserviceaccount \
--cluster=eks-cluster \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--role-name AmazonEKSLoadBalancerControllerRole \
--attach-policy-arn=arn:aws:iam::<iamid>:policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--approve


curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy_v1_to_v2_additional.json

aws iam create-policy \
  --policy-name AWSLoadBalancerControllerAdditionalIAMPolicy \
  --policy-document file://iam_policy_v1_to_v2_additional.json

aws iam attach-role-policy \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --policy-arn arn:aws:iam::<iamid>:policy/AWSLoadBalancerControllerAdditionalIAMPolicy


#https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/aws-load-balancer-controller.html
#certmanager, albcontroller.yaml(v2_4_7_full.yaml) 여기 대로 써라
kubectl apply \
    --validate=false \
    -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml

curl -Lo v2_4_7_full.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.4.7/v2_4_7_full.yaml

sed -i.bak -e '561,569d' ./v2_4_7_full.yaml

sed -i.bak -e 's|your-cluster-name|my-cluster|' ./v2_4_7_full.yaml
kubectl apply -f v2_4_7_full.yaml
curl -Lo v2_4_7_ingclass.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.4.7/v2_4_7_ingclass.yaml
kubectl apply -f v2_4_7_ingclass.yaml

kubectl get deployment -n kube-system aws-load-balancer-controller






echo "kubernetes_ready"