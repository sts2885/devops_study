
from minio import Minio
import pandas as pd

class Data_downloader :

    def __init__(self):
        self.minio_url = None
        self.minio_access_key = None
        self.minio_secret_key = None
        self.minio_region = None
        self.minio_bucket_name = None
        self.competition_name = None
        self.minio_client = None
        self.api = None
        
    def set_info_when_download_from_s3(self, 
                                       minio_url, 
                                       minio_access_key, 
                                       minio_secret_key,
                                       minio_region,
                                       minio_bucket_name,
                                       competition_name):
        #use minio for using s3
        self.minio_url = minio_url
        self.minio_access_key = minio_access_key
        self.minio_secret_key = minio_secret_key
        self.minio_region = minio_region
        self.minio_bucket_name = minio_bucket_name
        self.competition_name = competition_name

        self.minio_client = Minio(minio_url,
                                  access_key = minio_access_key,
                                  secret_key = minio_secret_key,
                                  region = minio_region
                                  )
        print(self.minio_client)
        
    def set_info_when_download_from_kaggle(self, 
                                           competition_name,
                                           ):
        #kaggle auth가 준비되어 있어야 함.
        self.competition_name = competition_name
        from kaggle.api.kaggle_api_extended import KaggleApi
        self.api = KaggleApi()
        self.api.authenticate()

    def get_info(self):
        return [self.minio_url,
            self.minio_access_key,
            self.minio_secret_key,
            self.minio_region,
            self.minio_bucket_name,
            self.competition_name]

    def download_all_from_kaggle(self, download_folder):
        self.api.competition_download_files(
            self.competition_name,
            path = download_folder
        )


    def download_some_files_from_kaggle(self, file_name_df):
        #not recommended kaggle api limit does not allow to download too many files each

        download_from = file_name_df['file_name_in_kaggle'].values
        download_to = file_name_df['download_to'].values

        for i in range(len(download_from)):
            self.api.competition_download_file(
                self.competition_name,
                download_from[i],
                path = download_to[i]
            )


    def download_from_s3(self, file_name_df, verbose=1):
        download_from = file_name_df['file_in_s3'].values
        download_to = file_name_df['download_to'].values

        for i in range(len(download_from)) :
            if verbose != 0:
                print(download_from[i], "download start")
            self.minio_client.fget_object(bucket_name = self.minio_bucket_name,
                                          object_name = download_from[i],
                                          file_path = download_to[i]
                                         )


