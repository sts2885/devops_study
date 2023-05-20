

# step 1 kubernetes cluster 생성 : 1 master, 2 worker

참고 블로그
https://medium.com/finda-tech/overview-8d169b2a54ff

강의를 듣고 실습을 진행하려고 했는데 실습에서는 GCP에서 만든 클러스터를 그냥 가져다 쓴다네?  
근데 난 GCP 공부할 계획이 지금은 없음.  
직접 만들어서 쓰려고 terraform까지 공부했는데...  

AWS에서 일단 terraform으로 간단한 vpc와 public subnet 1개만 써서 네트워크 만들어 놓고

spot instance 만들어서 실행하고 일단 손으로 따라 만드는 중

다 만들면 user data로 만들어서 자동 생성 예정.

user data가 각자 node에 설치는 되는데

master에 연결되려면 worker에 master에서 만든 token 등을 넣어야 한다.

s3 같은데에 뿌려놓고 worker에서 일정 주기로 확인하도록 코드 짜거나
생성 후에 조립해주는 스크립트가 있어야 한다.
=> 이러면 instance scaling이 안될거 같기도 하고


사용법

1. jupyter notebook을 준비 (저는 마침 예전에 쓰던 tensorflow-gpu jupyter docker image가 있어서 사용했습니다.)
2. 테라폼 설치(ipynb 파일에 있음)
3. boto3와 paramiko를 위한 aws 설정 파일(ipynb 파일에 있음)
4. terraform init
5. terraform apply
6. 나머지 스크립트 실행 (그냥 run all하면 됨.)
