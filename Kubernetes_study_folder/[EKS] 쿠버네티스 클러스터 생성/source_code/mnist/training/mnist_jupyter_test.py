#!/usr/bin/env python
# coding: utf-8

# In[ ]:





# http://www.gisdeveloper.co.kr/?p=8534

# In[ ]:





# In[ ]:





# 
# 
# tfjob 만드는 과정
# 
# 1. jupyter에서 단순 학습 테스트 (이 jupyter 파일)
# 
# 2. .py 코드로 만듦
# 
# 3. dockerize 시킴 => container가 실행될때 파이썬 코드 실행시키게 만듦
# 
# 4. 이미지를 registry에 띄움
# 
# 5. tfjob yaml 파일 작성함
# 
# 6. kubectl apply -f 로실행함.
# 
# 7. yaml파일을 jupyter에서 읽어서 pipeline으로 만듦
# 

# In[ ]:





# In[ ]:





# In[24]:


import tensorflow as tf
import tensorflow.keras as keras

from tensorflow.keras.layers import Flatten
from tensorflow.keras.layers import Dense
from tensorflow.keras.layers import Dropout

from tensorflow.keras.models import Model


# In[ ]:





# In[23]:


print(tf.__version__)
print(keras.__version__)


# In[ ]:





# In[ ]:





# In[5]:


(x_train, y_train) , (x_test, y_test) = keras.datasets.mnist.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0


# In[ ]:





# In[ ]:


#model = keras.models.Sequential([
#]


# In[32]:


input_x = keras.layers.Input(shape=(28,28))

x = Flatten()(input_x)
x = Dense(128, activation='relu')(x)
x = Dropout(0.2)(x)
output_y = Dense(10, activation='softmax')(x)

model = Model(inputs = input_x, outputs = output_y)


# In[ ]:





# In[34]:


model.summary()


# In[ ]:





# In[36]:


model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])


# In[ ]:





# In[37]:


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




