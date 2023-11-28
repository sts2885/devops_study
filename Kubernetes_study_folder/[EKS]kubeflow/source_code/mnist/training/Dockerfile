#escs34/mnist에 push해뒀습니다.
From tensorflow/tensorflow:2.12.0

ADD distributed_cnn_mnist_jupyter.py /var/source/distributed_cnn_mnist_jupyter.py

#코드 실행은 yaml파일에서 지정할거라 안해도 됨 (여기서 지정하거나, yaml 파일에서
 지정하거나 한번만.)
#예제코드 보니까 single은 yaml에서 distributed는 여기서 지정하길래 따라해봄

ENTRYPOINT ["python", "/var/source/distributed_cnn_mnist_jupyter.py"]
