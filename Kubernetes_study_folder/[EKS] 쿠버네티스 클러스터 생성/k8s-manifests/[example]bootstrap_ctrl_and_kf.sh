
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


#기존에 eksctl get iamserviceaccount를 통해 기존버전이 있으면 지우고 생성
#시작 전에 cloud formation에서 iamserviceaccount 손으로 삭제 하고 시작해야됨...
#https://us-east-1.console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/stackinfo?filteringText=&filteringStatus=active&viewNested=true&stackId=arn%3Aaws%3Acloudformation%3Aus-east-1%3A222170749288%3Astack%2Feksctl-eks-cluster-addon-iamserviceaccount-kube-system-aws-load-balancer-controller%2F82a68a90-1309-11ee-9d02-121d84b62ce9
#이거 생성한 세션에서 삭제 안하면 delete failed 뜨고 안됨.

#iam 들어가서 arn 찾아 놔야 함
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

#lb가 cert manager가 있어야 돌아감 그래서 kubeflow 안에 있는 거라도 꼭 깔아야 함.
#깔고 재시작 해야 됨... 그럴꺼면 그냥 여기서 한번 깔아보자
#깔고 안되면 kubeflow 깐 이후 재시작 해야지 뭐... 설치 순서르 ㄹ바꾸던...
#https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/aws-load-balancer-controller.html
#certmanager, albcontroller.yaml(v2_4_7_full.yaml) 여기 대로 써라
kubectl apply \
    --validate=false \
    -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml

sleep 20

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

#여기서 부터는 직접 입력해야 될듯 환경변수도 제대로 등록이 안되서, 싫으면 /etc/profile에 직접 append하거나
#버전을 eks 버전과 호환되는 버전을 검색후 (eks kubeflow compatible) 맞는 버전 기입
export KUBEFLOW_RELEASE_VERSION=v1.7.0
#이게 aws cli 버전이 아니라 kubeflow 깃허브에 release 버전 이름임
export AWS_RELEASE_VERSION=v1.7.0-aws-b1.0.2
git clone https://github.com/awslabs/kubeflow-manifests.git && cd kubeflow-manifests
git checkout ${AWS_RELEASE_VERSION}
git clone --branch ${KUBEFLOW_RELEASE_VERSION} https://github.com/kubeflow/manifests.git upstream

#노드 0 일때는 리소스 부족으로 이거 설치 안되는 듯 영원히 루프 도네
#2트째일떄 부터 아래 명령어 써라는 할 수 있는데
#문제는 jupyter reset이 아니면 boot script를 terraform에서 
#재시작 하지는 않음
# 노드 -> 1 -> 0 -> 1로 하자.

#이게 이전 설정들이 제대로 안되면 (lb controller 파드가 안켜진다거나) kubeflow 설치가 제대로 안됨. 재설치 하기도 힘들고

#자꾸 한번에 설치 안되면 kubeflow는 손으로 설치 할 수 밖에 없어...

while ! kustomize build /home/ubuntu/kubeflow-manifests/deployments/vanilla | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 30; done

#설치하면 현재는 istio-ingressgateway 가 cluster ip로 되어 있음
#kubeflow 홈페이지 들어가니까 해결책이 있었다.
#https://www.kubeflow.org/docs/distributions/ibm/deploy/authentication/
#지금은 스케일이 작아서 node port만 써도 되는데 커지면 lb가 들어가야 겠지
#kubectl patch svc istio-ingressgateway -n istio-system -p '{"spec":{"type":"ClusterIP"}}'
#kubectl patch svc istio-ingressgateway -n istio-system -p '{"spec":{"type":"LoadBalancer"}}'
#lb 쓰면 destroy하고 콘솔에서 따로 지우기 너무 귀찮음
kubectl patch svc istio-ingressgateway -n istio-system -p '{"spec":{"type":"NodePort"}}'


#In the login screen, use the default email (user@example.com) and password (12341234)
#kubectl port-forward --address 0.0.0.0 svc/istio-ingressgateway -n istio-system 8080:80
#nohup kubectl port-forward --address 0.0.0.0 svc/istio-ingressgateway -n istio-system 8080:80 &
#끄려면 프로세스 id 찾아내서 ps -e, kill 로 종료시키면 됨.


#service 출력시키자
kubectl get svc -n istio-system | grep istio-ingressgateway

#마지막에 노드 출력 시켜서 ip 보고 node port 들어가자
kubectl get node -o wide


echo "kubernetes_ready"