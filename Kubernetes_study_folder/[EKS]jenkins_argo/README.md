
현 클러스터 상황


1. public subnet 2개에 node 배포(외부 오픈됨)
2. secondary cidr로 pod 용 네트워크 대역, subnet을 따로 2개 열어줌
3. 들어가서 클러스터 구성 과정 ipynb 파일에 있음.
4. alb 설치 과정 boot_strap_example.sh 에 위치


준비할 시크릿
1. .aws
2. provider.tf
3. iam arm=> bootstrap에 "<iamid>"써야 alb controller설치가능
4. aws .pem 파일


사용법
1. [EKS] 쿠버네티스 클러스터 생성 폴더 내에 셋팅 필요
1-1. aws configure를 통해 만들어 놓은 .aws폴더를 현재 위치로 옮긴다. (bastion에 전송할 예정)
1-2. provider_example.tf를 복사해 provider.tf로 수정한 후 주석을 해제한다.
1-3. provider.tf에 access key, secret key를 넣는다. (terraform이 사용하기 위함)
1-4. boot_strap_example.sh 를 복사해 boot_strap.sh로 바꾸고, 내부에 <iamid>를 aws 콘솔에서 미리 준비한 iam의 arn에 있는 id값으로 수정한다.
1-5. terraform bastion.tf 파일에 pem key 입력
- key_name = "pem 키 이름 입력(.pem은 빼고)"
- resource "null_resource" "aws-configure", resource "null_resource" "k8s-manifests" 에 pem키 입력(.pem 포함)
- 이외에 terraform-backend에 s3 bucket명, dynamodb 등을 개인용으로 설정

2. terraform apply
2-1. terraform-backend folder에서 state를 s3에 저장하도록 설정
2-2. [EKS] 쿠버네티스 클러스터 폴더에서 terraform apply

3. 생성 완료 된 후. bastion server안에 있는 boot_strap.sh을 실행.

4. 실행후 node 갯수를 0으로 바꾸고, 이후에 다시 원하는 갯수로 node를 증가(secondary cidr subnet에 pod를 배치하기 위함.)

5. 위 과정을 .ipynb 안에 넣어둠.



#### 주의사항, terraform 버그로 vpc나 secondary cidr가 제대로 안만들어지거나, 안 지워지는 현상이 발생하는데 terraform apply를 한번더 실행하거나, 콘솔에서 직접 vpc를 삭제해야 한다.