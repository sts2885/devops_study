#!/usr/bin/env python
# coding: utf-8

# In[ ]:





# In[ ]:





# pipeline에서 environment 넣어준거라고 가정

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





# Data preprocessing : not recommended. Ad-hoc pipeline like this don't have any fault tolerance logic (like hadoop map reduce or spark). One fault can hurt all data integrity  
# But i will run this pipeline for fun!  

# In[ ]:





# In[7]:


import pandas as pd


# In[ ]:





# 쉽게 가기 위해서 이부분을 csv 가 아니라 리스트를 그냥 한번 읽게 하자.

# 잠깐... 테스트 할땐 그냥 전체를 다 읽게 하면 되잖아?

# In[8]:


import os

folder_path = pv_mount_name + pv_count

file_list = []
 
for path, subdirs, files in os.walk(folder_path):
    for name in files:
        file_list.append(os.path.join(path, name))


# In[ ]:





# 잠깐... 이러면 train test valid 구분은 어떻게 함?;;;  
# 잘생각해보니까... 구분할 필요가 있나? 다 map으로 돌릴껀데? 그러네?

# In[ ]:





# In[9]:


files_df = pd.DataFrame(data=file_list, columns=['files_path'])


# In[10]:


files_df


# In[ ]:





# .csv파일 등이 남아 있음

# In[11]:


files_df['files_path'].values


# In[ ]:





# In[12]:


#파일명이 npy 인것만 남김
files_df = files_df[files_df['files_path'].map(lambda name : name.split('.')[-1] == "npy")]


# In[13]:


files_df['files_path'].values


# In[ ]:





# In[ ]:


print(files_df['files_path'].values)


# In[ ]:





# In[ ]:





# In[14]:


#train_df = pd.read_csv('train.csv')
#valid_df = pd.read_csv('valid.csv')
#test_df = pd.read_csv('test.csv')


# In[ ]:





# In[15]:


from data_preprocessor import Npy_resize_preprocessor as NRP


# In[ ]:





# 원본 데이터 (256,256)
# npy_size : 450 GB Dataset
# img_size : 48.91GB
# 
# (128,128)
# npy_size :  112.5 GB
# img_size :  12.228260869565219 GB
# 
# (64,64)
# npy_size :  28.125 GB
# img_size :  3.0570652173913047 GB
# 
# (32,32)
# npy_size :  7.03125 GB
# img_size :  0.7642663043478262 GB

# In[ ]:





# In[16]:


def change_dir_by_setting(file_path, shape_format, file_format):
    #여기서 파일 이름에 따라서 추가 해서 넣어줘야 되는데? ㅈ 됬다. column에 넣으려니까 안되는데? => 기껏해야 list로 넣어야 됨.
    dirs = file_path.split('/')
    dirs[2] = dirs[2].replace('[(256,256),npy]', shape_format)
    dirs[-1] = dirs[-1].replace('.npy', file_format)
    return '/'.join(dirs)


# In[ ]:





# In[17]:


#ex

shape_list = [(256,256),(128,128),
              (64,64),(64,64),
              (32,32),(32,32)]

dir_list = ['[(256,256),jpg]',
            '[(128,128),jpg]',
            '[(64,64),npy]',
            '[(64,64),jpg]',
            '[(32,32),npy]',
            '[(32,32),jpg]'
           ]

format_list = [
    '.jpg',
    '.jpg',
    
    '.npy',
    '.jpg',
    
    '.npy',
    '.jpg',
]


#결국 짜긴 짰는데 복잡도가 끔찍하기 그지 없음...

def split_npy(file_name, arr):
    splitted_arr = []
    if file_name == 'human_pixel_masks.npy': #(256, 256, 1)
        splitted_arr = [arr[:,:,0]]
        #print("shape pixel:",splitted_arr[0].shape)
    elif file_name == 'human_individual_masks.npy' : #(256, 256, 1, 4)
        splitted_arr = [arr[:,:,0,i] for i in range(4)]
        #print("shape individual:",splitted_arr[0].shape)
    else: # (256,256,8)
        splitted_arr = [arr[:,:,i] for i in range(8)]
        #print("shape band:",splitted_arr[0].shape)
    return splitted_arr

def add_number_to_name(file_path, number):
    dirs = file_path.split('/')
    tmp = dirs[-1].split('.')
    tmp[0] += '_' + str(number)
    dirs[-1] = '.'.join(tmp)
    return '/'.join(dirs)
    
#file name이랑 
def read_change_save(file_path):
    #file_path = file_path[0]
    #print(file_path)
    arr = NRP.read_npy(file_path)#['files_path'])
    file_name = file_path.split("/")[-1]

    splitted_arr = split_npy(file_name, arr)

    for i in range(len(shape_list)):
        for j in range(len(splitted_arr)):
            reshaped_arr = NRP.resize(splitted_arr[j], shape_list[i])
            path_with_numbered = add_number_to_name(file_path, j)
            name_to_save = change_dir_by_setting(path_with_numbered, dir_list[i], format_list[i])
            NRP.write_with_format(reshaped_arr, name_to_save, format_list[i])


# In[ ]:





# In[18]:


files_df['files_path'].map(read_change_save)


# In[ ]:





# In[19]:


#train_df['files_path'].map(read_change_save)
#valid_df['files_path'].map(read_change_save)
#test_df['files_path'].map(read_change_save)


# In[ ]:





# # upload -> Zip 만들어서 올릴 계획이니까.

# In[ ]:





# In[20]:


import shutil

#그러네 이건 삭제 어떻게 하냐?
shutil.rmtree(folder_path+'/[(256,256),npy]')

import os

#level2에서는 애초에 pv에 담지도 않음.
rm_file = 'global_warming/google-research-identify-contrails-reduce-global-warming.zip'
if os.path.isfile(rm_file):
    os.remove(rm_file)


# In[ ]:





# In[21]:


import os

#folder_path = 'global_warming'

file_list = []
 
for path, subdirs, files in os.walk(folder_path):
    for name in files:
        file_list.append(os.path.join(path, name))


# In[ ]:





# In[22]:


tmp_df = pd.DataFrame(data=file_list, columns=['files_path'])


# In[23]:


tmp_df.head()


# In[ ]:





# In[24]:


def upload_file(file):
    #여기 업로드 하는 작업
    minio_client.fput_object(
        bucket_name = minio_bucket_name,
        object_name = file,
        file_path = file
    )
    return file


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

# In[26]:


from unzip_to_pv_manager import Unzip_to_pv_manager


# In[ ]:





# In[27]:


pv_mount_name = os.environ['pv_mount_name']
pv_count = os.environ['pv_count']


# In[ ]:





# In[28]:


unzip = Unzip_to_pv_manager()


# In[ ]:





# In[35]:


name_to_save= pv_count+'.zip'


# In[36]:


unzip.write_zip(files_base_dir = pv_mount_name+pv_count, name_to_save= name_to_save)
#unzip.write_zip(files_base_dir = pv_mount_name+pv_count, name_to_save=pv_count+'.zip')


# In[ ]:





# In[37]:


name_to_upload = 'global_warming/'+ pv_count+'.zip'


# In[39]:


print("name_of_file : ", name_to_save)
print("name_to_upload : ", name_to_upload)


# In[ ]:





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





# In[ ]:





# In[ ]:




