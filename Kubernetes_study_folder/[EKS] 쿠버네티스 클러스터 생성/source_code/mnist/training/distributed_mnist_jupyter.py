#!/usr/bin/env python
# coding: utf-8

# In[ ]:





# http://www.gisdeveloper.co.kr/?p=8534

# https://eunguru.tistory.com/237

# In[ ]:





# In[ ]:





# 
# 
# tfjob 만드는 과정 => 지나치게 복잡하고 불편한게 현실인듯
# 
# 1. jupyter에서 단순 학습 테스트 (이 jupyter 파일) (kubeflow jupyter)
# 
# 2. .py 코드로 만듦 (개발 환경에서) (내 노트북에서)
# 
# 3. dockerize 시킴 => container가 실행될때 파이썬 코드 실행시키게 만듦 (개발 환경에서) (내 노트북에서)
# 
# 4. 이미지를 registry에 띄움 (개발 환경에서) (내 노트북에서) (여기서 ECR에 올리고, kubernetes에 secret 넣고 돌릴거 생각하면 힘드니까 개인 dockerhub에 올림)
# 
# 5. tfjob yaml 파일 작성함 (개발 환경에서) (내 노트북에서)
# 
# 6. kubectl apply -f 로실행함. (kubernetes terminal에서)
# 
# 7. yaml파일을 jupyter에서 읽어서 pipeline으로 만듦 (kubeflow jupyter)
# 
# #총 3군데 환경을 계속 왔다갔다 해야 함.
# 
# #이게 중간에 yaml 파일만 고치면 바로 분산 학습이 될 줄 알았는데 잘 생각해보니까 학습 코드도 고쳐야됨 with strategy 넣어서
# #이 과정도 주피터로 돌리고 난 다음 넘어가야지

# In[ ]:





# In[ ]:





# In[2]:


import tensorflow as tf
import tensorflow.keras as keras

from tensorflow.keras.layers import Flatten
from tensorflow.keras.layers import Dense
from tensorflow.keras.layers import Dropout

from tensorflow.keras.models import Model


# In[ ]:





# In[3]:


print(tf.__version__)
print(keras.__version__)


# In[ ]:





# In[ ]:





# In[4]:


(x_train, y_train) , (x_test, y_test) = keras.datasets.mnist.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0


# In[ ]:





# In[5]:


strategy = tf.distribute.MirroredStrategy()


# In[6]:


print('num of machine: {}'.format(strategy.num_replicas_in_sync))


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:


#model = keras.models.Sequential([
#]


# In[7]:


with strategy.scope():
    input_x = keras.layers.Input(shape=(28,28))

    x = Flatten()(input_x)
    x = Dense(128, activation='relu')(x)
    x = Dropout(0.2)(x)
    output_y = Dense(10, activation='softmax')(x)

    model = Model(inputs = input_x, outputs = output_y)
    model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])


# In[ ]:





# In[8]:


model.summary()


# In[ ]:





# In[36]:





# In[ ]:





# In[ ]:


#0.5코어 주피터라 느리긴 하네
#짜놓고 보니까 valid set을 안넣었네?
model.fit(x_train, y_train, epochs=5)


# In[ ]:





# In[38]:


model.evaluate(x_test, y_test, verbose=2)


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:




