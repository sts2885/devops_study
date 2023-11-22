
#클래스로 만드는데 크게 의미가 없어져서...
#여기 로직을 넣을 생각이었는데 로직을 넣으면
#1회성이 되어버리기 때문에 간단 함수만 넣고
#로직은 ipynb에서

import numpy as np
import os
import cv2

class Npy_resize_preprocessor :
    #class used for static function
    #some array like only 0 's type is int8 => it cause failure on resize
    def read_npy(file_name):
        return np.load(file_name).astype(np.float32)

    def read_img(file_name, flag):
        return cv2.imread(file_name, flag).astype(np.float32)

    def resize(from_arr, to_shape):
        return cv2.resize(from_arr, dsize=to_shape)

    def write_to_img(arr, name_to_save):
        cv2.imwrite(name_to_save, arr)

    def write_to_npy(arr, name_to_save):
        np.save(name_to_save, arr)

    def write_with_format(arr, name_to_save, file_format):
        path_list = name_to_save.split('/')
        folder = '/'.join(path_list[:-1])
        if not os.path.exists(folder):
            os.makedirs(folder, exist_ok=True)
        
        if file_format == ".jpg":
            cv2.imwrite(name_to_save,arr)
        else:
            np.save(name_to_save, arr)


"""
import pandas as pd

#그러고보니까 dataframe은 어떻게 나눠받냐?
#=> csv파일로 나눠 저장해서 넣어놔야 겠네...
#=> pv에 저장할때 같이 넣어봐야 될듯
class Data_preprocessor:

    def __init__(self):
        pass

    def hook_funct_to_data(self, one_data, hook):
        hook(one_data)

    def hook_funct_to_dataframe(self, df, hook):
        df.map(hook)


import numpy as np
import cv2
class Npy_resize_preprocessor(Data_preprocessor) :

    #initiator
    #데이터 읽고 클래스 변수 저장했다가 => 지정한 포맷으로 reshape해서 저장시키면 될거 같은데?
    def __init__(self):
        self.arr_dict_by_shape = dict()

    #add read_img function if need
    def read_npy(self, file_name):
        arr = np.load(file_name)
        arr_shape = arr.shape
        self.arr_dict_by_shape[arr_shape] = arr

    #base on opencv
    def read_img(self, file_name, flag):
        arr = cv2.imread(file_name, flag)#읽은 시점에 ndarray
        arr_shape = arr.shape
        self.arr_dict_by_shape[arr_shape] = arr

    def resize(self, from_shape, to_shape):
        before = self.arr_dict_by_shape[str(from_shape)]
        after = cv2.resize(before, dsize=to_shape)
        self.arr_dict_by_shape[to_shape] = after

    def write_to_img(self, shape_to_save, name_to_save):
        img = self.arr_dict_by_shape[str(shape_to_save)]
        cv2.imwrite(name_to_save, img)

    def write_to_npy(self, shape_to_save, name_to_save):
        arr = self.arr_dict_by_shape[str(shape_to_save)]
        np.save(name_to_save, arr)




"""