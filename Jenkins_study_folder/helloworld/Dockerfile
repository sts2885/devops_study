#### 정리 ####

#정리#

#kustomize 설치 <- 이건 안해도 됨.
curl --silent --location "https://github.com/kubernetes-sigs/kustomize/releases/download/v3.2.0/kustomize_3.2.0_linux_amd64" -o /tmp/kustomize
sudo chmod +x /tmp/kustomize && sudo mv -v /tmp/kustomize /usr/local/bin


#jenkins 사양
(시스템 요구 사항)
(최소) Memory : 256MB / Disk : 10.0GB.
(권장) Memory : 512MB / Disk : 10.0GB.
 [jenkins] 최소사양 · CPU: 1 core · RAM: 1.75GB · HDD: 50GB SSD



#helm 설치 : 교재
curl -L https://git.io/get_helm.sh | bash -s -- --version v3.8.2

helm version




#jenkins 설치
https://peterica.tistory.com/189


#repository 정보 기입
helm repo add jenkins https://charts.jenkins.io

#repository 업데이트(내 서버에, 노트북에 인듯?)
helm repo update

#해당 repository에 들은 목록을 yaml파일로 <- 중간에 좀 수정하기 위함
helm show values jenkins/jenkins > jenkins-values.yaml

#네임스페이스를 쓰고 싶다면
kubectl create namespace jenkins

####트러블 슈팅 1####
여기서 jenkins-values.yaml을 들어가보면 기본 값만 있고
설정 하고 싶으면 뭐뭐뭐 해라 하는 주석들이 쭈룩 들어가 있음
너무 많아서 다 못보는데

그중에

jenkins pod는 deployment가 아니라 statefulset 형식으로 들어감
=> PVC, SC가 있어야 되는데
=> 기본 값은 (비워져 있음) <- 이건 sc를 만들지 않는다는 뜻임
=> 미리 만들어 놓아서 연결해야 함
(persistence: 안에 existingClaim이랑 storageClass에 채워 넣으면 됨
pvc 이름은 꼭 넣어줘야 되고
sc는 원하면 넣고 아니면 <storageClass> 라고 적어 넣으면
pvc에서 알아서 연결됨
참고로 둘 다 안넣으면 jenkins라는 이름의 pvc만 생기고 sc는 안생기며
sc 만 <storageClass>로 넣으면 pvc도 생성 못함.

PVC.yaml
StorageClass.yaml
파일 작성해야 함.

#storage class는 namespace 지정이 따로 없음.
# storage_class_csi_dynamic.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: csi-storageclass-dynamic
  namespace: jenkins
provisioner: cinder.csi.openstack.org
volumeBindingMode: Immediate

# pvc-dynamic.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-dynamic
  namespace: jenkins
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: csi-storageclass-dynamic





#수정한 내용 반영해서 설치
#jenkins : repository이름인거 같고
#-n jenkins : 위에서 만든 네임스페이스
#jenkins/jenkins : repository에 들어있는 이미지? 인거 같음
#-f jenkins-values.yaml 저장하고 수정한 yaml 파일
helm install jenkins -n jenkins jenkins/jenkins -f jenkins-values.yaml

####트러블 슈팅 2####
install로 설치하는 과정에서 permission denied가 많이 났음
=> yaml파일 보면 jenkins가 설치된 경로가 /var/jenkins_home인데
여기가 루트 권한 필요한 디렉토리라
runasuser를 1000에서 0으로 바꿔야 함

테스트에서는 전체 다 바꿨는데 맨 위만 바꿔도 되나 확인 해봐야.

기본 값 and controller에 있는거 0으로 바꾸고
securitycontext에 있는거 바꾸니까 돌아가다가 read-only file system이다 표기가 나옴
  containerSecurityContext: <- read only false로 바꿈


#설치된 리소스들 확인
kubectl get all -l app.kubernetes.io/name=jenkins

#계정 admin
#비밀번호 얻기
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo



#nginx ingress 설치
https://kubernetes.github.io/ingress-nginx/deploy/

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace

#원하면 헬름없이
#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml


#ingress.yaml은 반들고 60초 쯤 있으면 ip연결되네


#트러블 슈팅 3 : 왜 ingress에 연결이 안되지?
인그리스 나랑 펀진도 안된게

ip/jenkins => ip/login~~~로 바뀌어서 ingress에서 반응 못함.

https://stackoverflow.com/questions/52583371/how-to-specify-a-prefix-to-a-service-exposed-with-an-ingress
https://stackoverflow.com/questions/59844622/ingress-configuration-for-k8s-in-different-namespaces

이게 ingress에서  rewrite를 걸어주고
annotation에서 /$2를 넣어주면 nginx는 저 변수에 prefix를 저장해둠 <- 거기로 prefix 요청을 고정시킴
근데 링크에 jenkins가 사라지니까 화면에 아무것도 안나옴
=> jenkins values 파일에 jenkins 기본 prefix를 정하게 할 수 있음.
#######==> jenkins values 파일에 controller: 안에 주석처리된 부분중에 jenkinsUriPrefix: "/jenkins"를 쓰면됨(바꾸기도 가능)########
https://nauco.tistory.com/94
(alb는 rewrite가 없다고 함)

경우의 수
1. jenkins랑 ingress랑 같은 namespace => 그냥 쓰면 됨

2. 둘이 서로 다른 ingress - externalName을 ingress가 있는 namespace에 배치
- ingress는 다른 namespace의 서비스를 지정 할 수 없음.
- 이 externalName이라는게 k8s안에서 외부로 나가게 해주는 개념 (google.com같은 dns네임을 서비스로 지정 가능)
- 근데 k8s의 pod 안에는 클러스터 내부 dns 주소가 있음
- 그래서 이 주소를 externalName에 넣으면 접근 가능



jenkins values 파일에 controller: 안에 주석처리된 부분중에 jenkinsUriPrefix: "/jenkins"

#서비스명.네임스페이스명.svc.cluster.local
externalName: jenkins.jenkins.svc.cluster.local
###
apiVersion: v1
kind: Service
metadata:
  name: jenkins-external
  namespace: default #ingress가 있는 네임스페이스
spec:
  type: ExternalName
  externalName: jenkins.jenkins.svc.cluster.local


##ingress-at-same-namespace
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: jenkins-ingress
  namespace: jenkins
  annotations:
    ingress.kubernetes.io/rewrite-target: /$2
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /jenkins
        pathType: Prefix
        backend:
          service:
            name: jenkins
            port:
              number: 8080

##ingress-ingress-when-using-dff-namespace
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: jenkins-ingress
  annotations:
    ingress.kubernetes.io/rewrite-target: /$2
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /jenkins
        pathType: Prefix
        backend:
          service:
            name: jenkins-external
            port:
              number: 8080

curl ip/jenkins
터미널에 안나와서 혹시나 했는데 web ui로는 됨.


ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

####과정####

#kustomize 설치 <- 이건 안해도 됨.
curl --silent --location "https://github.com/kubernetes-sigs/kustomize/releases/download/v3.2.0/kustomize_3.2.0_linux_amd64" -o /tmp/kustomize
sudo chmod +x /tmp/kustomize && sudo mv -v /tmp/kustomize /usr/local/bin


#jenkins 사양
(시스템 요구 사항)
(최소) Memory : 256MB / Disk : 10.0GB.
(권장) Memory : 512MB / Disk : 10.0GB.
 [jenkins] 최소사양 · CPU: 1 core · RAM: 1.75GB · HDD: 50GB SSD



#helm 설치 : 교재
curl -L https://git.io/get_helm.sh | bash -s -- --version v3.8.2

helm version




#jenkins 설치
https://peterica.tistory.com/189


#repository 정보 기입
helm repo add jenkins https://charts.jenkins.io

#repository 업데이트(내 서버에, 노트북에 인듯?)
helm repo update

#해당 repository에 들은 목록을 yaml파일로 <- 중간에 좀 수정하기 위함
helm show values jenkins/jenkins > jenkins-values.yaml

#네임스페이스를 쓰고 싶다면
kubectl create namespace jenkins

####트러블 슈팅 1####
여기서 jenkins-values.yaml을 들어가보면 기본 값만 있고
설정 하고 싶으면 뭐뭐뭐 해라 하는 주석들이 쭈룩 들어가 있음
너무 많아서 다 못보는데

그중에

jenkins pod는 deployment가 아니라 statefulset 형식으로 들어감
=> PVC, SC가 있어야 되는데
=> 기본 값은 (비워져 있음) <- 이건 sc를 만들지 않는다는 뜻임
=> 미리 만들어 놓아서 연결해야 함
(persistence: 안에 existingClaim이랑 storageClass에 채워 넣으면 됨
pvc 이름은 꼭 넣어줘야 되고
sc는 원하면 넣고 아니면 <storageClass> 라고 적어 넣으면
pvc에서 알아서 연결됨
참고로 둘 다 안넣으면 jenkins라는 이름의 pvc만 생기고 sc는 안생기며
sc 만 <storageClass>로 넣으면 pvc도 생성 못함.

PVC.yaml
StorageClass.yaml
파일 작성해야 함.

#storage class는 namespace 지정이 따로 없음.
# storage_class_csi_dynamic.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: csi-storageclass-dynamic
  namespace: jenkins
provisioner: cinder.csi.openstack.org
volumeBindingMode: Immediate

# pvc-dynamic.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-dynamic
  namespace: jenkins
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: csi-storageclass-dynamic









#수정한 내용 반영해서 설치
#jenkins : repository이름인거 같고
#-n jenkins : 위에서 만든 네임스페이스
#jenkins/jenkins : repository에 들어있는 이미지? 인거 같음
#-f jenkins-values.yaml 저장하고 수정한 yaml 파일
helm install jenkins -n jenkins jenkins/jenkins -f jenkins-values.yaml

####트러블 슈팅 2####
install로 설치하는 과정에서 permission denied가 많이 났음
=> yaml파일 보면 jenkins가 설치된 경로가 /var/jenkins_home인데
여기가 루트 권한 필요한 디렉토리라
runasuser를 1000에서 0으로 바꿔야 함

테스트에서는 전체 다 바꿨는데 맨 위만 바꿔도 되나 확인 해봐야.

기본 값 and controller에 있는거 0으로 바꾸고
securitycontext에 있는거 바꾸니까 돌아가다가 read-only file system이다 표기가 나옴
  containerSecurityContext: <- read only false로 바꿈


#설치된 리소스들 확인
kubectl get all -l app.kubernetes.io/name=jenkins

#계정 admin
#비밀번호 얻기
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo



#nginx ingress 설치
https://kubernetes.github.io/ingress-nginx/deploy/

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace

#원하면 헬름없이
#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml


#ingress.yaml은 반들고 60초 쯤 있으면 ip연결되네


#트러블 슈팅 3 : 왜 ingress에 연결이 안되지?
인그리스 나랑 펀진도 안된게

login 할떄 링크가 이름이 바뀜
=> 그래서 ingress에 / 전체 경로로 하면 문제 안터짐
=> 이거는 external 넣어서? 지정해두면 되려나?

https://stackoverflow.com/questions/52583371/how-to-specify-a-prefix-to-a-service-exposed-with-an-ingress

이게 ingress에서  rewrite를 걸어주고
ingress 하나에 여러개의 서비스를 넣어주며 s안되나 보네

annotation에서 /$2를 넣어주면 nginx는 저 변수에 prefix를 저장해둠 <- 거기로 prefix 요청을 고정시킴
근데 링크에 jenkins가 사라지니까 화면에 아무것도 안나옴
=> jenkins values 파일에 jenkins 기본 prefix를 정하게 할 수 있음.


ㅡㅡㅡㅡㅡㅡㅡㅡㅡ
이게 링크가 문제면...
dns 네임을 따로 만들어야 되냐
external 



http://ip:80/jenkins

http://ip:80/login-sjiefljsef-jenkins


이거~~~ 아 드디어 알았네

jenkins url 은 /를 안쓸경우 생성할때 controller 항목에서 path를 지정해주는 부분이 있었네


   jenkinsUriPrefix: "/jenkins"
보니까 주석처리 되어 있었음


#helm 네임스페이스 변경해도 되는지.

타 네임스페이스 ingress에서 접근하려면
external name이 있어야 한다.



externalname service type

이거 k8s 클러스터 내부에서 외부의 dns 등을 찾아가기 위한 서비스임(google.com 같이)
=> 근데 이걸 이용해서 내부 dns 주소를 쳐줘도 되는듯?

#서비스명.네임스페이스명.svc.cluster.local
externalName: jenkins.jenkins.svc.cluster.local

apiVersion: v1
kind: Service
metadata:
  name: jenkins-external
  namespace: default
spec:
  type: ExternalName
  externalName: jenkins.jenkins.svc.cluster.local


지금은 ingress가 default에 있으니까 이렇게 두고

ingress가 jenkins namespace에서 연결되면 사실 이마저도 필요 없음.
curl 133.186.153.11/jenkins
[centos@masternode nginx-ingress-controller]$ vi cafe-ingress-uri.yaml
[centos@masternode nginx-ingress-controller]$ vi cafe-ingress-uri.yaml
[centos@masternode nginx-ingress-controller]$ cat cafe-ingress-uri.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: jenkins-ingress
  annotations:
    ingress.kubernetes.io/rewrite-target: /$2
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /jenkins
        pathType: Prefix
        backend:
          service:
            name: jenkins-external
            port:
              number: 8080

터미널에 안나와서 혹시나 했는데 web ui로는 됨.


#ingress혹시 파일 이름 바꿔도 되나 한번 보고
됨

이제 하나 남음
#ingress 네임스페이스 변경해도 돌아가는지만 보면 될거 같음


클리어

그동안은 왤케 lb연결이 안됐을까?
=> 한번 기본예제로 연결을 뚫었어야 됐나? 암튼....








ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ





#과정#


#jenkins 사양
(시스템 요구 사항)
(최소) Memory : 256MB / Disk : 10.0GB.
(권장) Memory : 512MB / Disk : 10.0GB.
 [jenkins] 최소사양 · CPU: 1 core · RAM: 1.75GB · HDD: 50GB SSD



#helm 설치 : 교재
curl -L https://git.io/get_helm.sh | bash -s -- --version v3.8.2

helm version


#kustomize 설치
curl --silent --location "https://github.com/kubernetes-sigs/kustomize/releases/download/v3.2.0/kustomize_3.2.0_linux_amd64" -o /tmp/kustomize
sudo chmod +x /tmp/kustomize && sudo mv -v /tmp/kustomize /usr/local/bin



#jenkins 설치
https://peterica.tistory.com/189


helm repo add jenkins https://charts.jenkins.io

helm repo update

helm show values jenkins/jenkins > jenkins-values.yaml

helm install jenkins jenkins/jenkins -f jenkins-values.yaml

- admin 유저 비밀번호 셋팅을 gownsmms audfud어가 나오는듯? <- exec해서 들어가서 직접 바꾸라고

svc를 ingress에 달아보자.

kubectl get all -l app.kubernetes.io/name=jenkins

보면 service에 jenkins랑 jenkins-agent가 있는데

비밀번호 얻기
kubectl exec --namespace default -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo


#nginx ingress 설치
https://kubernetes.github.io/ingress-nginx/deploy/

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml


nks에서 이렇게 만들어 놓으니까 생성이 안됨.
(NFS를 안써서 그런가 하고 edit를 해보니까 rwo로 잘 되어 있음
아마 스토리지 클래스가 지정이 안된듯?)

손으로 따로 sc를 만들어서 추가하고
edit로 바운드 시켜줬는데
show 로 만든 파일 잘 수정하면 될듯


하니까 바운드도 되고 pod initialize 시작됐는데
Init:CrashLoopBackOff

Back-off restarting failed container init in pod jenkins-0
자주 일어나는 현상인가 보네 자동 완성되네

https://github.com/jenkinsci/helm-charts/issues/185

로그 보라는데

mount를 여섯 + 3 군데를 하는데? dljr ek 넣어줘야 되느거 아니냐?

로그 에는 컨테이너 이름 지정해줘야 되서

kubectl get pod 이름 -o jsonpath={..spec.containers[*].name} | xargs -n1
kubectl get pod jenkins-0 -o jsonpath={..spec.containers[*].name} | xargs -n1
jenkins
config-reload

https://github.com/jenkinsci/helm-charts/issues/185

천천히 내려보니까 컨테이너가 부서져서 이사람도 나처럼 로그 못봄

여기서는 jenkins의 업데이트 site의 커넥션 이슈라는데?

플러그인 껴서 다운로드 받으라는데...

kubectl logs jenkins-0 -c init
disable Setup Wizard
/var/jenkins_config/apply_config.sh: 4: cannot create /var/jenkins_home/jenkins.install.UpgradeWizard.state: Permission denied

permission denied?

sc 때문인가?

nhn가이드의 sc에 provisioner가 2종 있는데 엤날 꺼 써서그런가?
https://stackoverflow.com/questions/43544370/kubernetes-how-to-set-volumemount-user-group-and-file-permissions

컨테이너 내부에서 root 유저 말고 다른유저를 자체적으로 사용해서 생기는 문제

근데 문제는 edit 해서 들어가보니까 security context가 5군데에 있음.

kubectl logs jenkins-0
Error from server (BadRequest): a container name must be specified for pod jenkins-0, choose one of: 
[config-reload-init init jenkins config-reload]

###config-reload-init###
 kubectl logs jenkins-0 config-reload-init
{"time": "2023-10-24T04:33:41.105060+00:00", "msg": "Starting collector", "level": "INFO"}
{"time": "2023-10-24T04:33:41.105288+00:00", "msg": "No folder annotation was provided, defaulting to k8s-sidecar-target-directory", "level": "WARNING"}
{"time": "2023-10-24T04:33:41.105422+00:00", "msg": "Loading incluster config ...", "level": "INFO"}
{"time": "2023-10-24T04:33:41.105991+00:00", "msg": "Config for cluster api at 'https://10.254.0.1:443' loaded...", "level": "INFO"}
{"time": "2023-10-24T04:33:41.106103+00:00", "msg": "Unique filenames will not be enforced.", "level": "INFO"}
{"time": "2023-10-24T04:33:41.106184+00:00", "msg": "5xx response content will not be enabled.", "level": "INFO"}
{"time": "2023-10-24T04:33:41.106470+00:00", "msg": "Performing list-based sync on configmap resources: {'label_selector': 'jenkins-jenkins-config', 'namespace': 'default'}", "level": "INFO"}
{"time": "2023-10-24T04:33:41.130743+00:00", "msg": "Writing /var/jenkins_home/casc_configs/jcasc-default-config.yaml (ascii)", "level": "INFO"}
#문제 없음

###init###
kubectl logs jenkins-0 -c init
disable Setup Wizard
/var/jenkins_config/apply_config.sh: 4: cannot create /var/jenkins_home/jenkins.install.UpgradeWizard.state: Permission denied

###jenkins###
kubectl logs jenkins-0 -c jenkins
Error from server (BadRequest): container "jenkins" in pod "jenkins-0" is waiting to start: PodInitializing
#파드 생성이 안되었다

###config-reload###
kubectl logs jenkins-0 -c config-reload
Error from server (BadRequest): container "config-reload" in pod "jenkins-0" is waiting to start: PodInitializing
#마찬가지다

init에서 결국 접근 문제다.
여기만 해결 되면 되는 걸까? NFS가 아니어도 되나?

보니까 sc 랑pvc 기입하는 부분이 있네

누가 블로그에서 eks에 연결하는거 설명하는데

pvc도 따로 만들어서...

이거로 한번 더해보고 생각해보자.


#보니까 sc를 한군데만 넣은거나 다름 없는듯? 아닌가?
kubectl describe statefulset.apps/jenkins

    Mounts:
      /run/secrets/additional from jenkins-secrets (ro)
      /tmp from tmp-volume (rw)
      /usr/share/jenkins/ref/plugins/ from plugin-dir (rw)
      /var/jenkins_cache from jenkins-cache (rw)
      /var/jenkins_config from jenkins-config (ro)
      /var/jenkins_home from jenkins-home (rw)
      /var/jenkins_home/casc_configs from sc-config-volume (rw)
   config-reload:
    Image:      kiwigrid/k8s-sidecar:1.24.4
    Port:       <none>
    Host Port:  <none>
    Environment:
      POD_NAME:            (v1:metadata.name)
      LABEL:              jenkins-jenkins-config
      FOLDER:             /var/jenkins_home/casc_configs
      NAMESPACE:          default
      REQ_URL:            http://localhost:8080/reload-configuration-as-code/?casc-reload-token=$(POD_NAME)
      REQ_METHOD:         POST
      REQ_RETRY_CONNECT:  10
    Mounts:
      /var/jenkins_home from jenkins-home (rw)
      /var/jenkins_home/casc_configs from sc-config-volume (rw)
  Volumes:
   plugins:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
   jenkins-config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      jenkins
    Optional:  false
   plugin-dir:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
   jenkins-secrets:
    Type:                Projected (a volume that contains injected data from multiple sources)
    SecretName:          jenkins
    SecretOptionalName:  <nil>
   jenkins-cache:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
   jenkins-home:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  jenkins
    ReadOnly:   false
   sc-config-volume:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
   tmp-volume:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
Volume Claims:  <none>
Events:         <none>




이걸로 다시

# storage_class_csi_dynamic.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: csi-storageclass-dynamic
provisioner: cinder.csi.openstack.org
volumeBindingMode: Immediate

# pvc-dynamic.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-dynamic
  namespace: default
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: csi-storageclass-dynamic


그리고 jenkins-values.yaml 파일 내에 sc랑 pvc 이름을 넣음

뭐야 이렇게 지울 수 있네
helm uninstall jenkins


pvc 이름을 jenkins로 만들어 넣어

이미 그 이름의 pvc가 있다고 나옴

찬찬히 읽어보니까
yaml파일 storageclass 부분 바로 위에
existingClaim이라고 있음 몰라서 헤멨네

나는 data source라고 되어 있는데인줄 알았는데 거기에 perssitentvolumeclaim이라는 하위항목이 있어서

주석에 다 적혀있는데

existingClaim : 존재하는 pvc를 사용할까요?

사용한다 => 동적 프로비저닝을 원하면 storageclass 부분에 <storageClass>라고만 적어 넣어라
여기에 이름을 적어 넣으면 정적 프로비저닝 밖에 안된다.

아예 비워놓으면 (undefined) => sc 자체를 생성안한다 => 이래서 안됐던 거네

잠깐... 
존재하는 pvc 라는거 자체에 sc 이름이 들어가야 되는거 아니냐?




kubectl logs jenkins-0
Error from server (BadRequest): a container name must be specified for pod jenkins-0, choose one of: [config-reload-init init jenkins config-reload]



이렇게 연결은 했는데 

결국엔 돌고 돌아서 퍼미션 디나이드
/var/jenkins_config/apply_config.sh: 4: cannot create /var/jenkins_home/                                                                          jenkins.install.UpgradeWizard.state: Permission denied

cannot create니까 w 가 필요한거네

read만 바꾸면 에러터지는데?


runas user 만 0으로 하니까 됐음

jenkins 설치 경로가 root 권한 필요한 디렉토리여서
/var/jenkins_home <- yaml파일 보면 있음

ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ



#https://docs.nhncloud.com/ko/Container/NKS/ko/user-guide/#nginx-ingress-controller
# cafe-ingress-uri.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: cafe-ingress-uri
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /tea
        pathType: Prefix
        backend:
          service:
            name: tea-svc
            port:
              number: 80
      - path: /coffee
        pathType: Prefix
        backend:
          service:
            name: coffee-svc
            port:
              number: 80


드디어 설치했는데 싹 날리고 다시 해보자.

드디어 됐는데 ingress는 아직 연결 못함




pass Qbh8XNbEjxsMUe5LGbju12






















