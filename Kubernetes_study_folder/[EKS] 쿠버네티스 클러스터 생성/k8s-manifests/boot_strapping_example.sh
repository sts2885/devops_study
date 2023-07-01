
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




##alb controller 설치
#eksctl
curl --location \
"https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin

eksctl version





curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=eks-cluster --approve


echo "detach role for lb controller iam service account and wait 5 sec"
#이전에 쓴 eksctl iam service account 지우기
aws iam detach-role-policy \
--role-name AmazonEKSLoadBalancerControllerRole \
--policy-arn arn:aws:iam::<iam_id>:policy/AWSLoadBalancerControllerAdditionalIAMPolicy

sleep 5

echo "delete lb controller iam service account and wait5 sec"


eksctl delete iamserviceaccount \
--cluster eks-cluster \
--namespace kube-system \
--name aws-load-balancer-controller

sleep 5

#aws lb controller 설치
#https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/aws-load-balancer-controller.html

eksctl create iamserviceaccount \
--cluster=eks-cluster \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--role-name AmazonEKSLoadBalancerControllerRole \
--attach-policy-arn=arn:aws:iam::<iam_id>:policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--approve

sleep 5



curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy_v1_to_v2_additional.json

aws iam create-policy \
  --policy-name AWSLoadBalancerControllerAdditionalIAMPolicy \
  --policy-document file://iam_policy_v1_to_v2_additional.json

aws iam attach-role-policy \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --policy-arn arn:aws:iam::<iam_id>:policy/AWSLoadBalancerControllerAdditionalIAMPolicy


sleep 5


#certmanager는 kubeflow에 있는 거로 쓸 예정
#https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/aws-load-balancer-controller.html
#certmanager, albcontroller.yaml(v2_4_7_full.yaml) 여기 대로 써라
#kubectl apply \
#    --validate=false \
#    -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml

#가끔 iam service account 설치 되도  한번에 이거 설치 안될때 있음
curl -Lo v2_4_7_full.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.4.7/v2_4_7_full.yaml

sed -i.bak -e '561,569d' ./v2_4_7_full.yaml

sed -i.bak -e 's|your-cluster-name|eks-cluster|' ./v2_4_7_full.yaml
kubectl apply -f v2_4_7_full.yaml
curl -Lo v2_4_7_ingclass.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.4.7/v2_4_7_ingclass.yaml
kubectl apply -f v2_4_7_ingclass.yaml

kubectl get deployment -n kube-system aws-load-balancer-controller



echo "detach role for ebs csi driver iam service account and wait 5 sec"
#이전에 쓴 eksctl iam service account 지우기
aws iam detach-role-policy \
--role-name AmazonEKS_EBS_CSI_DriverRole \
--policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy

sleep 5

echo "delete ebs csi driver iam service account and wait5 sec"


eksctl delete iamserviceaccount \
--cluster eks-cluster \
--namespace kube-system \
--name ebs-csi-controller-sa

sleep 5

###ebs csi

eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster eks-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --role-only \
  --role-name AmazonEKS_EBS_CSI_DriverRole

sleep 5

eksctl create addon --name aws-ebs-csi-driver --cluster eks-cluster --service-account-role-arn arn:aws:iam::<iam_id>:role/AmazonEKS_EBS_CSI_DriverRole --force

sleep 5


####efs csi driver###

#delete past version

echo "detach role for efs csi driver iam service account and wait 5 sec"
#이전에 쓴 eksctl iam service account 지우기
aws iam detach-role-policy \
--role-name AmazonEKS_EFS_CSI_DriverRole \
--policy-arn arn:aws:iam::<iam_id>:policy/AmazonEKS_EFS_CSI_Driver_Policy

sleep 5

echo "delete efs csi driver iam service account and wait5 sec"


eksctl delete iamserviceaccount \
--cluster eks-cluster \
--namespace kube-system \
--name efs-csi-controller-sa

sleep 5


curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/master/docs/iam-policy-example.json

aws iam create-policy \
    --policy-name AmazonEKS_EFS_CSI_Driver_Policy \
    --policy-document file://iam-policy-example.json



eksctl create iamserviceaccount \
    --cluster eks-cluster \
    --namespace kube-system \
    --name efs-csi-controller-sa \
    --attach-policy-arn arn:aws:iam::<iam_id>:policy/AmazonEKS_EFS_CSI_Driver_Policy \
    --approve \
    --region us-east-1\
    --role-name AmazonEKS_EFS_CSI_DriverRole


#https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/efs-csi.html

#helm 설치 : 교재
curl -L https://git.io/get_helm.sh | bash -s -- --version v3.8.2

helm version

helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/

helm repo update


#602401143452.dkr.ecr.us-east-1.amazonaws.com
#컨테이너 이미지 주소. 리전별로 값이 다를 수 있음.
helm upgrade -i aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \
--namespace kube-system \
--set image.repository=602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/aws-efs-csi-driver \
--set controller.serviceAccount.create=false \
--set controller.serviceAccount.name=efs-csi-controller-sa

kubectl get pods -n kube-system | grep efs-csi-control


##### kubeflow 설치 #####
#kustomize 설치
curl --silent --location "https://github.com/kubernetes-sigs/kustomize/releases/download/v3.2.0/kustomize_3.2.0_linux_amd64" -o /tmp/kustomize
sudo chmod +x /tmp/kustomize && sudo mv -v /tmp/kustomize /usr/local/bin

#버전을 eks 버전과 호환되는 버전을 검색후 (eks kubeflow compatible) 맞는 버전 기입
export KUBEFLOW_RELEASE_VERSION=v1.7.0
#이게 aws cli 버전이 아니라 kubeflow 깃허브에 release 버전 이름임
export AWS_RELEASE_VERSION=v1.7.0-aws-b1.0.2
git clone GitHub - awslabs/kubeflow-manifests: KubeFlow on AWS  && cd kubeflow-manifests
git checkout ${AWS_RELEASE_VERSION}
git clone --branch ${KUBEFLOW_RELEASE_VERSION} GitHub - kubeflow/manifests: A repository for Kustomize manifests  upstream

while ! kustomize build deployments/vanilla | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 30; done

#In the login screen, use the default email (user@example.com) and password (12341234)
#kubectl port-forward --address 0.0.0.0 svc/istio-ingressgateway -n istio-system 8080:80

echo "kubernetes_ready"