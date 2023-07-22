 # -*- coding: utf-8 -*

#kubeflow spark 검색하다 나왔는데 스파크 보다는 pipeline 코드가 있어서한번 따라쳐 보자.
#https://kils-log-of-develop.tistory.com/804

#이거도 한번 해봐야 될듯
#https://sbakiu.medium.com/orchestrating-spark-jobs-with-kubeflow-for-ml-workflows-830f802a99fe



#간단 예제부터... 인데 여기도 중간에 하다 마네

#import kfp

#def simple_echo(i):
#    return i

#simpleStrongTypedFunction = \
#    kfp.components.func_to_container_op(simple_code)

##

#foo = simpleStronglyTypedFunction(1)
#print(type(foo))

#@dsl.pipeline(
#    name='XGBoost Trainer',
#    description='A trainer that does end-to-end distributed training for XGBoost models'
#) 
#여기에 s3에서 데이터 가져올꺼면 s3위치를 넣어줘야 하는 거고.
#근데 이게 s3를 minio통해서 접근함

#def xgb_train_pipeline(
#    output='gs:구글스토리지저장소',
#    project='your-gcp-project',
#    cluster_name = 'xgb-%s' % dsl.RUN_ID_PLACEHOLDER, #이런걸 넣었어야됐다고?
#    #실행 자체가 안되는 코드니까 이게 맞는지 틀린지 검증을 할 수 있어야지...
#    region='us-central1',
#    train_data='gs저장소',
#    eval_data='gs://ml-저장소',
#    schema='저장소',
#    target='resolution',
#    rounds=200,
#    workers=2,
#    true_label='ACTION'
#):



#https://blog.min.io/building-an-ml-data-pipeline-with-minio-and-kubeflow-v2-0/

#minif 쿠브플로우 파이프라인에


#1. 쿠브플로우 =-> min io , minio -> s3 or kubernetes -> s3
#2. 쿠브플로우 -> s3로 한번에 기능?




















