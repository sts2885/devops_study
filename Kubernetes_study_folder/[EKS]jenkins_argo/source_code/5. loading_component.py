
import kfp

tfx_csv_gen = kfp.components.load_component_from_file(
    "pipelines-0.2.5/components/tfx/ExampleGen/CsvExampleGen/component.yaml"
)

tfx_statistic_gen = kfp.components.load_component_from_file(
    "pipelines-0.2.5/components/tfx/StatisticsGen/component.yaml"
)

tfx_schema_gen = kfp.components.load_component_from_file(
    "pipelines-0.2.5/components/tfx/SchemaGen/component.yaml"
)

tfx_example_validator = kfp.components.load_component_from_file(
    "pipelines-0.2.5/components/tfx/ExampleValidator/component.yaml"
)

fetch = kfp.dsl.ContainerOp(name = "download",
                            image="busybox",
                            command=['sh', '-c'],
                            arguments = [
                                'sleep 1;'
                                'mkdir -p /tmp/data'
                                'wget ' + data_url +
                                '-O /tmp/data/results.csv'
                            ],
                            file_outputs = {'downloaded': '/tmp/data'})

records_example = tfx_csv_gen(input_base=fetch.output)

stats = tfx_statistic_gen(input_data=records_example.output)

schema_op = tfx_schema_gen(stats.output)



## schema를 locally 하게 다운로드 받자.
import tensorflow_data_validation as tfdv

schema = tfdv.load_schema_text("schema_info_2")
tfdv.display_schema(schema)

tfx_example_validator(stats = stats.outputs['output'],
                      schema=schema_op.outputs['output'])


import tensorflow as tf
import tensorflow_transform as tft
from tensorflow_transform.tf_metadata import schema_utils

def preprocessing_fn(inputs):
    pass

outputs = {}
#TFT business logic goes here

outputs["body_stuff"] = tft.compute_adn_apply_vocabulary(inputs["body"], top_k=1000)

transformed_output = tfx_transform(
    input_data = records_example.output,
    schema=schema_op.outputs['output'],
    module_file = module_file
)







