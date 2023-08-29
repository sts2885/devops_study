import zipfile
import os

class Unzip_to_pv_manager:

    def __init__(self):
        pass

    def write_zip(self, files_base_dir, name_to_save) :
        #get directory structure
        file_list = []
        for path, subdirs, files in os.walk(files_base_dir):
            for name in files:
                file_list.append(os.path.join(path, name))

        with zipfile.ZipFile(name_to_save, 'w') as zip_ref:
            for file in file_list:
                zip_ref.write(file)
        
    def extract_all(self, file_name, extract_to):
        with zipfile.ZipFile(file_name, 'r') as zip_ref:
            zip_ref.extractall(extract_to)
 
    def extract_to_multiple_path(self, file_name, folder_list_to_extract, verbose=0):
        #test/ <= 이거 압축 어떻게 풀리는지 한번 봐야 됨... 중간 중간 전체 다 풀라고 할 수 있음.
        #압축 파일 하나 s3에서 받아서 돌려보자.
        zip_ref = zipfile.ZipFile(file_name, 'r')
        zip_name_list = zip_ref.namelist()

        div = len(folder_list_to_extract)
        len_zip_files = len(zip_name_list)
        len_zip_files_div = len_zip_files // div
        
        file_list_list = []

        #split list by number of extract path
        for i in range(0, div-1):
            file_list_list.append(zip_name_list[i*len_zip_files_div : (i+1)*len_zip_files_div])
        #last shard
        file_list_list.append(zip_name_list[(div-1)*len_zip_files_div : ])

        for i in range(div):
            if verbose == 1:
                print(i,'th folder start : ', folder_list_to_extract[i])
            for file in file_list_list[i]:
                #이 path 밑에 압축된 폴더 디렉토리 구조가 생김
                zip_ref.extract(file, folder_list_to_extract[i])

        zip_ref.close()

        return file_list_list