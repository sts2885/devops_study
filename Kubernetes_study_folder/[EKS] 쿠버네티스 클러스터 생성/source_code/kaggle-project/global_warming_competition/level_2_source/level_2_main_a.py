#!/usr/bin/env python
# coding: utf-8

# In[ ]:





# In[ ]:





# pipeline에서 environment 넣어준거라고 가정

# # #모든 과정은 dataframe을 가지고 있다는 전제하에 진행함.#

# In[ ]:





# # STAGE 1

# In[ ]:





# ### read os env variable

# In[1]:


from minio import Minio
import os


# In[2]:


minio_url = os.environ["minio_url"]
minio_access_key = os.environ['minio_access_key']
minio_secret_key = os.environ['minio_secret_key']
minio_region = os.environ['minio_region']
minio_bucket_name = os.environ['minio_bucket_name']
competition_name = os.environ['competition_name']


# In[ ]:





# In[3]:


pv_mount_name = os.environ['pv_mount_name']
pv_count = os.environ['pv_count']


# In[ ]:





# ### kaggle setting

# In[8]:


kaggle_access_key = os.environ["kaggle_access_key"]
kaggle_secret_key = os.environ["kaggle_secret_key"]


# In[ ]:





# In[9]:


competition_name = os.environ['competition_name']


# In[ ]:





# In[10]:


#필요한 위치에 정보 입력

kaggle_json =  '{"username":"%s","key":"%s"}'%(kaggle_access_key, kaggle_secret_key)

os.makedirs('~/.kaggle', exist_ok=True)

with open('~/.kaggle/kaggle.json', 'w') as f:
    f.write(kaggle_json)

#root 권한이면 써야됨.
os.makedirs('/.kaggle')
with open('/.kaggle/kaggle.json', 'w') as f:
    f.write(kaggle_json)
    
os.makedirs('/home/ubuntu/.kaggle')
with open('/home/ubuntu/.kaggle/kaggle.json', 'w') as f:
    f.write(kaggle_json)

#os.makedirs('/home/jovyan/.kaggle')
#with open('/home/jovyan/.kaggle/kaggle.json', 'w') as f:
#    f.write(kaggle_json)


# In[ ]:





# # Download 받을 폴더 위치

# In[ ]:





# In[11]:


import pandas as pd


# In[12]:


from_file_to_file = [['google-research-identify-contrails-reduce-global-warming.zip', 'global_warming/google-research-identify-contrails-reduce-global-warming.zip']]

columns = ['file_in_s3', 'download_to']

download_df = pd.DataFrame(data=from_file_to_file, columns=columns)


# In[ ]:





# In[13]:


download_df


# In[ ]:





# In[ ]:





# # download from s3

# In[14]:


from data_downloader import Data_downloader


# In[15]:


data_downloader = Data_downloader()

data_downloader.set_info_when_download_from_s3(minio_url, minio_access_key, minio_secret_key, minio_region, minio_bucket_name, competition_name)


# In[16]:


data_downloader.download_from_s3(file_name_df=download_df)


# In[ ]:





# ### download from kaggle 실전에서는 이걸 써야

# In[17]:


#data_downloader = Data_downloader()

#data_downloader.set_info_when_download_from_kaggle(competition_name)


# In[18]:


#data_downloader.download_all_from_kaggle(download_folder = "test_test")


# In[ ]:





# # extract data to specific directory

# In[19]:


from unzip_to_pv_manager import Unzip_to_pv_manager


# In[20]:


unzip = Unzip_to_pv_manager()


# In[21]:


zip_file_extracted_file = [['global_warming/google-research-identify-contrails-reduce-global-warming.zip', 'global_warming/[(256,256),npy]/google-research-identify-contrails-reduce-global-warming']]


# In[ ]:





# In[ ]:





# In[22]:


import os


# In[23]:


num_pv = int(pv_count)


# In[ ]:





# In[24]:


pv_dir_list = [pv_mount_name+str(count) for count in range(1, num_pv+1)]


# In[ ]:





# jupyter에서 테스트 하려고 둔 거고 실제로는 필요없음 mount하면서 dir 생성도 하기 때문에

# In[25]:


import os

for pv_name in pv_dir_list:
    if os.path.exists(pv_name) == False:
        os.makedirs(pv_name, exist_ok=True)


# In[ ]:





# # 사전에 2GB 데이터를 가지고 extract_all이랑 extract의 시간 차이를 비교해봤는데, 거의 유사했음.

# ![image.png](attachment:3988a464-dbb5-4000-bfb3-fe97b882b539.png)

# 그래서 그냥 extract를 pv로 바로 해버리면?  
# 디스크에 저장 후 다른 pv로 옮기는 시간 자체가 0이 된다.  
# (병렬로 작업하면 오히려 더 빨라질 수 도 있다 이말이다.)

# In[ ]:





# In[26]:


pv_list = []

for i in range(1, num_pv+1):
    pv_list.append(pv_mount_name+str(i)+"/[(256,256),npy]/")


# In[ ]:





# In[27]:


pv_list


# In[ ]:





# In[28]:


unzip.extract_to_multiple_path('./global_warming/google-research-identify-contrails-reduce-global-warming.zip', pv_list, verbose=1)


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:




