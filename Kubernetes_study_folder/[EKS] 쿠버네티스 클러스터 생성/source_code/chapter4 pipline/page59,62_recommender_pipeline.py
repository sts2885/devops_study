

#와 진짜 kubeflow, pipeline, argo, 이책 다 미쳤다.

#꼴랑 100줄도 안되는 코드 한번 따라쳤을 뿐인데
#머리가 부서지는 수준의 충격을 받았어
#이 과정이 이렇게 심플해보이게 변한다고?


#여기에서 쓰는 lightbend 라는 곳의 recommender가
#한 깃허브에 올라와있음
#근데 이 사람이 openshift에서 일하나봐?
#그쪽 설치 설명 밖에 없고
#docker hub에는 recommender만 딱 없음
#그래서 github에서 clone 해서 dockerfile로 빌드 해야 함
#2023-07-08
#https://github.com/lightbend/kubeflow-recommender
'''
#docker 설치
apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository --yes "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce docker-ce-cli containerd.io
systemctl start docker
apt-get update

git clone https://github.com/lightbend/kubeflow-recommender.git

docker build -t lightbend/ml-tf-recommender:0.6 /home/ubuntu/kubeflow-recommender/recommender/.

#### 한참 해보고 ####
#이거 아무래도 github에 올리던 양반이 image를 싹 날린거 같은데?
책에서는 버전 0.1
블로그에서는 0.2
orelly에서는 0.6을 쓰고 있는데
docker hub 들어가보니까 4년전에 올린 0.0.1 이거 이외에는 없고
github에서도 이거 써라 라고 되어 있음
예전 버전 이후로 이사람이 아마 openshift로 넘어간거 같은데 그러면서
deprecated해버린듯?
뭔짓을 해도 실행 안됨
하필이면 쿠버네티스 버전 올리면서 지금 docker도 안씀.
근데 컨테이너 생성도 안되는건 너무 했다.

겁나 열심히 공부했는데 실행도 못해봄...
계속 에러만 나서...

잠깐. 이거 혹시 구글 용 인가?

GCP : GCS(Google Cloud Storage) - hypemarc - 하이프마크

hypemarc.com
https://hypemarc.com › gcp-cloud-storage
GCS란 언제 어디서나 데이터를 저장하고 가져올 수 있는 객체 저장소로 데이터를 저장 ... 변경할 수 없는 데이터 조각이 버킷이라는 컨테이너에 저장되며 시작됩니다.

엥? chapter 9에서 case에 minio연결 예제가 없음

그럼 되는지 안되는지는 어떻게 아냐...
큰일인데?

그리고 생각보다 chapter 9 예제가 엄청 짧음
'''



import kfp

import kfp.dsl

from kubernetes import client as k8s_client

from istio_auth import get_istio_auth_session

KUBEFLOW_ENDPOINT = "http://ip:8080"
KUBEFLOW_USERNAME = "user@example.com"
KUBEFLOW_PASSWORD = "12341234"

auth_session = get_istio_auth_session(
    url = KUBEFLOW_ENDPOINT,
    username =  KUBEFLOW_USERNAME,
    password = KUBEFLOW_PASSWORD
)

client = kfp.Client(host=f"{KUBEFLOW_ENDPOINT}/pipeline",
                    cookies=auth_session["session_cookie"]
                    )

print(client.list_experiments())


@dsl.pipeline(
    name='Recommender model update',
    description = 'Demonstrate usage of pipelines for multi-step model update'
)
#와... 코드 읽기 개힘들어
#갑자기 코드 1~2줄 쓰다가 급발진 한 이유를 보니까 이게 db 업데이트 같은 느낌인듯?
#보니까 왜 이렇게 짰는지 알겠네
#기본적으로 container 생성 -> 이미지 선택 -> 환경변수 추가
#이거는 데이터 준비 -> 모델이 있는 컨테이너 집어넣어서 학습
#이 과정을 보여주는거야. 실제 모델을 돌리지는 않지만
#데이터 전달 과정을 보여주는 거지
#=> 돌리나? 이미지가 조금씩 다른데?
#이미지 = 무슨 동작할지 선택
#.add_env = minio연결로 데이터 연결
#.add_env 1 = minio 주소
#.add_env 2 = minio access key
#.add_env 3 = minio secret key
def recommender_pipeline():
    #Load new data
    #minio key, secrete 집어넣고 컨테이너 생성
    #kubernetes에 직접 명령시키도록 k8s_client도 넣고
    #왜 얘는 카프카에서 꺼내온게 아닐까? 데이터가 커서 s3에 들어있어야 하니까?
    #그러네 s3, hdfs 같은데에 들어가 있어야 하니까.
    #보면 볼수록 이 파이프라인이라는거 개쩐다.
    #쓰면 s3, hdfs 온프레미스 환경 상관없이 무슨 환경이든 연결 시킬수 있네?
    data = dsl.ContainerOp(
        name='updatedata',
        #이게 이미지 직접 선택하는거
        #함수형 프로그래밍 방식으로
        image='lightbend/recommender-data-update-publisher:0.2') \
        .add_env_variable(k8s_client.V1EnvVar(name='MINIO_URL',
            #kubernetes dns 인가?
            value = 'http://minio-service.kubeflow.svc.cluster.local:9000',)) \
        .add_env_variable(k8s_client.V1EnvVar(name='MINIO_KEY', value='minio')) \
        .add_env_variable(k8s_client.V1EnvVar(name='MINIO_SECRET', value='minio123'))
    
    #train the model
    train = dsl.ContainerOp(
        name = 'trainmodel',
        image='lightbend/ml-tf-recommender:0.2') \
        .add_env_variable(k8s_client.V1EnvVar(name='MINIO_URL',
            value='minio-service.kubeflow.svc.cluster.local:9000')) \
        .add_env_variable(k8s_client.V1EnvVar(name='MINIO_KEY', value='minio')) \
        .add_env_variable(k8s_client.V1EnvVar(name='MINIO_SECRET', value='minio123'))

    #컨테이너에 데이터 집어넣고 학습
    train.after(data)

    #publish new model
    #이번에는 minio만 연결하는게 아니네
    #이번에는 publisher 이미지 다운받고
    #minio연결하고
    #모델을 카프카에 넣어버린다.
    #https://always-kimkim.tistory.com/entry/kafka101-broker
    #들어가며 카프카는 메시지를 생산하는 프로듀서와 소비하는 컨슈머, 그리고 그 사이에서 메시지를 저장, 전달하는 브로커(Broker)로 구성됩니다.
    #그리고 recomendel url을 입력해버리네
    #serving part로 들어가면 kf serving이나 seldon이 저기 들어가겠지?
    publish = dsl.ContainerOp(
        name='publishmodel',
        image='lightbend/recommender-model-publisher:0.2') \
        .add_env_variable(k8s_client.V1EnvVar(name='MINIO_URL',
                value='minio-service.kubeflow.svc.cluster.local:9000')) \
        .add_env_variable(k8s_client.V1EnvVar(name='MINIO_KEY', value='minio')) \
        .add_env_variable(k8s_client.V1EnvVar(name='MINIO_SECRET', value='minio123')) \
        .add_env_variable(k8s_client.V1EnvVar(name='KAFKA_BROKERS',
            value='cloudflow-kafka-brokers.cloudflow.svc.cluster.local:9092')) \
        .add_env_variable(k8s_client.V1EnvVar(name='DEFAULT_RECOMMENDER_URL',
            value='http://recommendermodelserver.kubflow.svc.cluster.local:8501')) \
        .add_env_variable(k8s_client.V1EnvVar(name='ALTERNATIVE_RECOMMANDER_URL',
            value='http://recommendermodelserver1.kubeflow.svc.cluster.local:8501'))

    publish.after(train)

from kfp import compiler
exp = client.create_experiment(name='mdupdate2')
print(client.list_experiments())

exp = client.get_experiment(experiment_name = "mdupdate")

compiler.Compiler().compile(recommender_pipeline, "pipeline.tar.gz")

run = client.run_pipeline(exp.id, "pipeline1", "pipeline.tar.gz")


##################
gcs_download_componet = kfp.components.load_component_from_file(
        "pipelines-0.2.5/components/google-cloud/storage/download/component.yaml"
)
###################

dl_op = gcs_download_component(
        gcs_path="gs://ml-pipeline-playground/tensorflow-tfx-repo/tfx/components/testdata/external/csv"
) #your path goes here











