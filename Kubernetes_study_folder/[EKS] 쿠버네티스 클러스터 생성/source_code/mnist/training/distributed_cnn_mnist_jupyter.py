#!/usr/bin/env python
# coding: utf-8

# In[ ]:





# In[ ]:





# In[2]:


import tensorflow as tf
import tensorflow.keras as keras

from tensorflow.keras.layers import Flatten
from tensorflow.keras.layers import Dense
from tensorflow.keras.layers import Dropout
from tensorflow.keras.layers import Conv2D
from tensorflow.keras.layers import BatchNormalization

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


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[9]:


with strategy.scope():
    input_x = keras.layers.Input(shape=(28,28,1))

    x = Conv2D(64, kernel_size=3, activation='relu')(input_x)
    x = BatchNormalization()(x)
    x = Conv2D(32, kernel_size=3, activation='relu')(x)
    x = BatchNormalization()(x)
    x = Conv2D(16, kernel_size=3, activation='relu')(x)

    x = Flatten()(x)
    x = Dense(32, activation='relu')(x)
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


model.fit(x_train, y_train, epochs=5, batch_size=256)


# In[ ]:





# In[38]:


model.evaluate(x_test, y_test, verbose=2)


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:




