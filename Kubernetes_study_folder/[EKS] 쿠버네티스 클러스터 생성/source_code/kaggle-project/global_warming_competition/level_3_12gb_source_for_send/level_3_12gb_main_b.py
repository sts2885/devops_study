#!/usr/bin/env python
# coding: utf-8

# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# # STAGE 2  
# 일단은 container 1개당 pv 1개 씩이 가도록 설계함.

# In[ ]:





# In[4]:


import os

minio_url = os.environ["minio_url"]
minio_access_key = os.environ['minio_access_key']
minio_secret_key = os.environ['minio_secret_key']
minio_region = os.environ['minio_region']
minio_bucket_name = os.environ['minio_bucket_name']
competition_name = os.environ['competition_name']

pv_mount_name = os.environ['pv_mount_name']
pv_count = os.environ['pv_count']
download_from = os.environ['download_from']


# In[ ]:





# In[5]:


from minio import Minio


# In[6]:


#아마 minio 글로벌 변수 선언해야 될거 같은데...
#global minio_client
minio_client = Minio(
    minio_url,
    access_key = minio_access_key,
    secret_key = minio_secret_key,
    region = minio_region
)


# In[ ]:


print("minio connected")


# Data preprocessing : not recommended. Ad-hoc pipeline like this don't have any fault tolerance logic (like hadoop map reduce or spark). One fault can hurt all data integrity  
# But i will run this pipeline for fun!  

# In[ ]:





# In[ ]:





# make df for current files (use this instead of csv file)  
# (files contain extracted .npy files and json files from kaggle)

# In[7]:


import pandas as pd


# In[8]:


import os

folder_path = pv_mount_name + pv_count

file_list = []
 
for path, subdirs, files in os.walk(folder_path):
    for name in files:
        file_list.append(os.path.join(path, name))


# In[ ]:





# In[9]:


files_df = pd.DataFrame(data=file_list, columns=['files_path'])


# In[10]:


files_df.head()


# In[ ]:


print("extracted file_list uploaded")


# In[ ]:





# .csv파일 등이 남아 있음

# In[11]:


print(files_df['files_path'].head(5).values)


# In[ ]:





# In[ ]:


print("get df with only named .npy, not metadata(json, csv, etc)")


# In[12]:


#파일명이 npy 인것만 남김
files_df = files_df[files_df['files_path'].map(lambda name : name.split('.')[-1] == "npy")]


# In[13]:


files_df['files_path'].head(5).values


# In[ ]:





# In[14]:


#train_df = pd.read_csv('train.csv')
#valid_df = pd.read_csv('valid.csv')
#test_df = pd.read_csv('test.csv')


# In[ ]:





# In[15]:


from data_preprocessor import Npy_resize_preprocessor as NRP


# In[ ]:


print("get df with only name start with band")


# In[16]:


files_df = files_df[ files_df['files_path'].map(lambda name : name.split('/')[-1][:4] == 'band') ]


# In[ ]:





# In[17]:


print(files_df['files_path'].head(5).values)


# In[ ]:





# In[ ]:


print("get df with only 8,9,10 band")


# In[18]:


# use band 8,9,10
files_df_to_change = files_df[ files_df['files_path'].map(lambda name : int(name.split('/')[-1][5:7]) < 11) ]


# In[19]:


print(files_df_to_change['files_path'].head(5).values)


# In[ ]:





# In[ ]:





# In[ ]:


print("get df with band 11~16 to remove")


# In[20]:


# remove band 11~16
files_df_to_remove = files_df[ files_df['files_path'].map(lambda name : int(name.split('/')[-1][5:7]) >= 11) ]


# In[21]:


print(files_df_to_remove['files_path'].head(10).values)


# In[ ]:


print("remove 11~16 band")


# In[25]:


if len(files_df_to_remove) != 0:
    files_df_to_remove['files_path'].map(lambda name : os.remove(name))
else:
    print("files_df_to_remove len is 0", len(files_df_to_remove))


# In[ ]:





# In[ ]:





# In[ ]:





# In[26]:


def read_change_save(file_path):
    
    arr = NRP.read_npy(file_path)
    frame_5 = arr[5]
    
    frame_5 = frame_5.astype('float16')
    
    #제자리에 원본 날리고 넣어두면 됨.
    NRP.write_with_format(frame_5, name_to_save=file_path,file_format='.npy')


# In[ ]:





# In[ ]:


print("change data with 8,9,10 band")


# In[27]:


if len(files_df_to_change) != 0:
    files_df_to_change['files_path'].map(read_change_save)
else:
    print("files_df_to_change len is 0", len(files_df_to_change))


# In[ ]:





# In[28]:


#train_df['files_path'].map(read_change_save)
#valid_df['files_path'].map(read_change_save)
#test_df['files_path'].map(read_change_save)


# In[ ]:





# # upload -> Zip 만들어서 올릴 계획이니까.

# In[ ]:


#No need to get left files list. If you want to make list of data with csv, It can help,


# In[29]:


"""
import os

#folder_path = 'global_warming'

file_list = []
 
for path, subdirs, files in os.walk(folder_path):
    for name in files:
        file_list.append(os.path.join(path, name))
"""


# In[ ]:





# In[30]:


#tmp_df = pd.DataFrame(data=file_list, columns=['files_path'])


# In[31]:


#tmp_df.head()


# In[ ]:





# In[32]:


'''
def upload_file(file):
    #여기 업로드 하는 작업
    minio_client.fput_object(
        bucket_name = minio_bucket_name,
        object_name = file,
        file_path = file
    )
    return file
'''


# In[ ]:





# In[25]:


#tmp_df['files_path'].map(upload_file)


# In[ ]:





# In[ ]:





# # PV dir에 있는 값들 압축

# In[ ]:





# 원한다면 pv를 퍼뜨린 것처럼  
# pv를 다시 모아서 압축 할 수 도 있겠지만  
# 여기서는 4조각으로 나누면 3GB 씩 해서 훨씬 쓰기 좋을테니까 그냥 두겠다.  
# => 반드시 하나의 zip으로 두고 싶다면 파이프 라인을 하나 늘려서 pv를 합치면 된다.

# In[ ]:





# 1 container 1pv 설계이기 때문에 여러 pv에 있을거라는 가정은 그냥 날리겠음.

# In[33]:


from unzip_to_pv_manager import Unzip_to_pv_manager


# In[ ]:





# In[34]:


pv_mount_name = os.environ['pv_mount_name']
pv_count = os.environ['pv_count']


# In[ ]:





# In[35]:


unzip = Unzip_to_pv_manager()


# In[ ]:





# In[36]:


name_to_save= pv_count+'.zip'


# In[ ]:





# In[ ]:


print("extract folder")


# In[37]:


unzip.write_zip(files_base_dir = pv_mount_name+pv_count, name_to_save= name_to_save)
#unzip.write_zip(files_base_dir = pv_mount_name+pv_count, name_to_save=pv_count+'.zip')


# In[ ]:





# In[38]:


name_to_upload = 'global_warming/'+ pv_count+'.zip'


# In[39]:


print("name_of_file : ", name_to_save)
print("name_to_upload : ", name_to_upload)


# In[ ]:





# In[40]:


def upload_from_to(from_file, to_file):
    #여기 업로드 하는 작업
    minio_client.fput_object(
        bucket_name = minio_bucket_name,
        object_name = to_file,
        file_path = from_file
    )
    return from_file


# In[ ]:





# In[41]:


upload_from_to(name_to_save, name_to_upload)


# In[ ]:




