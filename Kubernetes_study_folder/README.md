

# step 2 kubernetes 예제 실습

클러스터 생성법
1. jupyter notebook을 준비 (저는 마침 예전에 쓰던 tensorflow-gpu jupyter docker image가 있어서 사용했습니다.)
2. 테라폼 설치(ipynb 파일에 있음)
3. boto3와 paramiko를 위한 aws 설정 파일(ipynb 파일에 있음)
4. terraform init
5. terraform apply (비용절약을 위해 worker는 spot instance를 사용함. 가격이 너무 낮으면 인스턴스 안켜짐)
6. 나머지 스크립트 실행 (그냥 4~6까지 전부 run all 한번 하면 됨.)
7. 다 사용후 terraform destroy
