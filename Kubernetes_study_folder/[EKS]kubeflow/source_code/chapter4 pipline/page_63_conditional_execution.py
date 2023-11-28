

import kfp
from kfp import dsl
from kfp.components import func_to_container_op, InputPath, OutputPath

#from istio_auth import get_istio_auth_session

from istio_auth_with_client import client




@func_to_container_op
def get_random_int_op(minimum: int, maximum: int) -> int:
    """난수 생성 => minimum ~ maximum 사이의 값(이상,이하)"""
    import random #이 안에 넣어야 컨테이너 안에 들어간다.
    result = random.randint(minimum, maximum)
    print(result)
    return result

@func_to_container_op
def process_small_op(data: int):
    """작은 숫자들을 process해라"""
    print("processing small result", data)
    return

@func_to_container_op
def process_medium_op(data:int):
    print("medium result", data)
    return

@func_to_container_op
def process_large_op(data: int):
    print("high", data)
    return


@dsl.pipeline(
    name='Conditional execution pipeline',
    description = 'Show how to use dsl.Condition().'
)
def conditional_pipeline():
    number = get_random_int_op(0,100).output
    with dsl.Condition(number < 10):
        process_small_op(number)
    with dsl.Condition(number > 10 and number < 50):
        process_medium_op(number)
    with dsl.Condition(number > 50):
        process_large_op(number)

client.create_run_from_pipeline_func(conditional_pipeline, arguments={})


















