# -*- coding: utf-8 -*-

import kfp
"""
#세션 연결하기
KUBEFLOW_ENDPOINT = "http://54.237.247.74:8080"
KUBEFLOW_USERNAME = "user@example.com"
KUBEFLOW_PASSWORD = "12341234"

auth_session = get_istio_auth_session(
    url=KUBEFLOW_ENDPOINT,
    username=KUBEFLOW_USERNAME,
    password=KUBEFLOW_PASSWORD
)

client = kfp.Client(host=f"{KUBEFLOW_ENDPOINT}/pipeline", cookies=auth_session["session_cookie"])
print(client.list_experiments())
"""
import kfp

import kfp.dsl as dsl
'''
def simple_echo(i : int) -> int:
    return i


#simple_echo를 kubeflow pipeline operation으로 감싸고 싶다.
#아래 메소드가 팩토리 function을 리턴한다.
#책을 읽어보면 아무리 봐도 여기에 simple echo fn를 넣어야 될거 같은데... dead 대신
simpleStronglyTypedFunction = kfp.components.func_to_container_op(deadSimpleIntEchoFn)
#simpleStornglyTypedFunction = kfp.components.func_to_container_ops(simple_echo)
#여기서 GPU 사용을 설정 할 수도 있다.
#kfp.components.func_to_container_op(deadSimpleIntEchoFn).set_gpu_limit(NUM_GPUS)

#foo = simpleStronglyTypedFunction(1)
#type(foo)

@kfp.dsl.pipeline(
    name='Simple Echo'
    description='This is an echo pipeline. It echos numbers.'
)

def echo_pipeline(param_1: kfp.dsl.PipelineParam):
    my_step = simpleStronglyTypedFunction(i= param_1)

#구조 너무 헷갈리네 => simple Strongly TypedFunction 을 컴파일 해서 컨테이너로 만드는 거 같은데?
kfp.compiler.Compiler().compile(echo_pipeline, 'echo-pipeline.zip')
'''
###################################################
#밑에 짠 다음에 보니까 위랑 아래랑 다른 파이프라인이네#
###################################################

#두번째 function 준비
def add(a: float, b: float) -> float:
    #calculates sum of two arguments
    return a + b

#책에는 위처럼 적혀 있었는데 읽어보니까 저자 멋대로 줄인거 같은데?
#얘는 simple echo 처럼 describe를 안넣네?
#add_op = comp.func_to_container_op(add)
add_op = kfp.components.func_to_container_op(add)

#세번째 function => numpy를 써보자.
#numpy는 여기서 global import가 되어 있어 container에 패키지를 넣을 필요가 없지만
#다른 패키지 같은건 사용하는 컨테이너에 설치되어 잇는지 확인해야 한다.

from typing import NamedTuple
def my_divmod(dividend: float, divisor: float) -> \
NamedTuple('MyDivmodOutput', [('quotient', float), ('remainder', float)]):
    #Divides two numbers and cacluate the quotient and remainder

    #imports inside a component function:

    import numpy as np

    #=> 그냥 안에 nested function 쓸수 있다고 보여주려고 넣었다고 함.
    def divmod_helper(dividend, divisor):
        return np.divmod(dividend, divisor)
    
    #나눔당하는 것을 , 나눠서 , 몫과, 나머지로 만듦
    (quotient, remainder) = divmod_helper(dividend, divisor)

    from collections import namedtuple
    #이런 모양의 튜플을 만들어서
    divmod_output = namedtuple('MyDivmodOutput', ['quotient', 'remainder'])
    #튜플안에 데이터 담아서 출력
    return divmod_output(quotient, remainder)

#특정 컨테이너를 불러서 넣어도 된다.
#특정 패키지를 원하면 그게 들어있는 컨테이너를 부르면 되는 구나.
divmod_op = kfp.components.func_to_container_op(my_divmod, base_image='tensorflow/tensorflow:1.14.0-py3')


#이제 이것들을 모아서 파이프라인으로 빋르하자.
#데코레이터 (http get, post 함수 같은거 머리 위에 이게 있음 데코레이터 패턴임)
#여기서 작성되는 내용이 다른 함수에 파라미터로 전달되고 웹서버 프레임워크 같은데에서는 import나 inheretance 등으로 가려져 있는 거지
@dsl.pipeline(
    name='Calculation pipeline',
    description='A toy pipeline that performs arithmetic calculations.'
)
#input 부분을 만드는 듯 => 아니고 그래프 조립이네
def calc_pipeline(
    a='a',#이걸 에코하고? -> 이거 파라미터
    b='7',#b랑 c를 나누는데 쓰는듯? => 상수
    c='17',
):
    #이거 보니까... a가 들어오는 parameter인가 본데?
    #파이프라인 만들고 나면 원하는 값 그때그때 넣어 줄 수 있는 느낌인건가?
    #(a+4)
    add_task = add_op(a,4)

    #(a+4)//b
    divmod_task = divmod_op(add_task.output, b)

    #(a+4)//b + c
    result_task = add_op(divmod_task.outputs['quotient'], c)

client = kfp.Client()

arguments = {'a':'7'}#, 'b':'8'}

client.create_run_from_pipeline_func(calc_pipeline, arguments=arguments)























