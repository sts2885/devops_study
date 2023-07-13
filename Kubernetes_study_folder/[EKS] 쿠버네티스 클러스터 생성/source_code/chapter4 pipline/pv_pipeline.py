


import kfp
from kfp import dsl
from kfp.components import func_to_container_op, InputPath, OutputPath

#from istio_auth import get_istio_auth_session

from istio_auth_with_client import client
################
"""
kubeflow pipeline에서 storage를 쓰는 방식

1. pv를 통해 container에 자동 마운트 => 이 경우에 컨테이너 A에서 작업한 PV를 컨테이너 B로 옮겨 달 수 있다.
2. MinIO를 통한 스토리지 사용(1) : PV
3. MinIO를 통한 스토리지 사용(2) : s3, gcs에 read write
"""

#이게 다 좋은데 terminate 시키면 EBS가 안없어지고 남아있는데?
#주피너 리셋 시키거나 날려도 안없어지려나? => 리셋은 남아있음
#existing pv쓰는 설정으로 낭비 안하고 쓸 수 있긴 함.
#왠지 모르겠는데 다시 돌리니까 코드 돌아갈떄 5GB에 붙음 => 기존게 붙은건가? 지우고 다시 붙인건가?ㄴㄴㄴㄴ

@dsl.pipeline(
    name = "test",
    description = "testestsets"
)
def pv_test_pipeline():
    vop = dsl.VolumeOp(name="create_pvc",
                        resource_name="my-pvc-2",
                        size="5Gi",
                        modes=dsl.VOLUME_MODE_RWO)
    data_url = "https://www.cs.toronto.edu/~kriz/cifar-10-python.tar.gz"
    #EBS가 자동 생성 되서 데이터 다운로드 받더니 EBS가 자동으로 떨어짐
    #잠만 이렇게 되어 있으면 원하는 위치에 받은건 아니잖아.
    
    #download 1까지는 잘 됨 => 그래서 minio에 data log가 남은듯 
    step1 = kfp.dsl.ContainerOp(
        name="download",
        image="busybox",
        command=["sh","-c"],
        arguments=[
            "sleep 1;",
            "mkdir -p /mnt/data;",
            "wget" + data_url + "-o /mnt/data/"
        ],
        pvolumes={"/mnt": vop.volume}
        #file_outputs = {"downloaded", "/tmp/data"}
    )

    step2 = kfp.dsl.ContainerOp(
        name="download",
        image="busybox",
        command=["sh","-c"],
        arguments=[
            "sleep 1;",
            "mkdir -p /mnt/data2;",
            "wget" + data_url + "-o /mnt/data2/",
        ],
        #이렇게 하면 이전에 쓴 ebs를 똑 떼서 붙여서 쓰는거 같은데?
        pvolumes={"/mnt": step1.pvolume,
                 # "/mnt": dsl.PipelineVolume(pvc="existing-pvc")
                 }
        #file_outputs = {"downloaded", "/tmp/data"}
    )
    
    step2.after(step1)


#GCS는 컴포넌트 하나만 다운로드 받으면 gcs를 바로 pv로 마운트 해버릴 수 있는거 같다.

########
from kfp import compiler
exp = client.create_experiment(name="test")
exp_test = client.get_experiment(experiment_name = "test")
compiler.Compiler().compile(pv_test_pipeline, "pipeline.tar.gz")
run = client.run_pipeline(exp.id, "pipeline1", "pipeline.tar.gz")



















