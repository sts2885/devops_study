 # -*- coding: utf-8 -*


#!wget https://github.com/kubeflow/pipelines/archive/0.2.5.tar.gz
#!tar -xvf 0.2.5.tar.gz


tfx_csv_gen = kfp.components.load_component_from_file(
    "pipelines-0.2.5/components/tfx/ExampleGen/CsvExampleGen/component.yml"
)

tfx_statistic_gen = kfp.components.load_component_from_file(
    "pipelines-0.2.5/components/tfx/StatisticsGen/component.yaml"
)

tfx_schema_gen = kfp.components.load_component_from_file(
    "pipelines-0.2.5/components/tfx/SchemaGen/components.yaml"
)

tfx_example_validator = kfp.components.load_component_from_file(
    "pipelines-0.2.5/components/tfx/ExampleValidator/component.yaml"
)

#pip3 install tfx tensorflow-data-validation

#여기서 뜬금 없이 data_url이라고 적어놨는데 


#이 아래 컨테이너는 만약 데이터 받아서 minio 저장한다면 이렇게 된다 하는 내용인거 같음
#이거를 써야 한다는 얘기는 아닌 거 같음
#이전에 download container를 따로 뒀었으니까
#라고 생각했는데, 보니까 "니가 알아서 되게 이어 넣어^^" 같은데?
#download pipeline은?ㄴㄴ
"""

fetch = kfp.dsl.ContainerOp(name='download',
                            image='busybox',
                            command=['sh', '-c'],
                            arguments=[
                                'sleep 1;',
                                'mkdir -p /tmp/data',
                                'wget ' + data_url + '-O /tmp/data/result.csv'
                            ],
                            file_outputs={'downloaded': '/tmp/data'}
                            )
                            #pv에 데이터가 있으면 filesystem/get_file 컴포넌트를 쓸 수 있다.

records_example = tfx_csv_gen(input_base=fetch.output)
stats = tfx_statistic_gen(input_data = records_example.output)
schema_op = tfx_schema_gen(stats.output)

import tensorflow_data_validation as tfdv

schema = tfdv.load_schema_text("schema_info_2")
tfdv.display_schema(schema)

tfx_example_validator(stats=stats.outputs['output'],
                    schema=schema_op.outputs['output']
)
"""


















