


#pvc 할당 코드

dvop = dsl.VolumeOp(name="create_pvc",
                    resource_name="my-pvc-2",
                    size="5Gi"
                    )

'''
#minio는 kubeflow에 설치되어있어 이렇게 ui를연결해볼 수 있다.
kubectl port-forward -n kubeflow svc/minio-service 9000:9000 &


pushd ~/bin
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod a+x mc

#minIO CLI 직접 사용
mc config host add minio http://localhost:9000 minio minio123

mc mb minio/kf-book-examples



'''


fetch = kfp.dsl.ContainerOp(name='download', image='busybox', command=['sh','-c'],
                            arguments=[
                                'sleep 1;', #책에는 쉼표가 없는데 이게 맞는거 아니냐?
                                'mkdir -p /tmp/data;',
                                'wget' + data_url + '-O /tmp/data/results.csv'
                            ],
                            file_outputs = {'downloaded':'/tmp/data'}
                            )

