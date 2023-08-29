
#업로드는 까다로운거 없음. 그냥 병렬처리 1회로 끝임 업로드 함수를 로컬 함수로 빼자.

#minio가 어디서 선언되야 되냐?ㄴㄴ


#이거 이렇게 해도 되는거 맞냐?....
def upload_from_to(from_file, to_file):
    #여기 업로드 하는 작업
    minio_client.fput_object(
        bucket_name = minio_bucket_name,
        object_name = to_file,
        file_path = from_file
    )
    return from_file

def upload_file(file):
    #여기 업로드 하는 작업
    minio_client.fput_object(
        bucket_name = minio_bucket_name,
        object_name = file,
        file_path = file
    )
    return file


class Data_uploader:

    def __init__(self, minio_client, minio_bucket_name):
        self.minio_client = minio_client
        self.minio_bucket_name = minio_bucket_name

    def upload_file(self, file):
        #여기 업로드 하는 작업
        self.minio_client.fput_object(
            bucket_name = self.minio_bucket_name,
            object_name = file,
            file_path = file
        )
        return file

    def upload_from_to(self, from_file, to_file):
        #여기 업로드 하는 작업
        self.minio_client.fput_object(
            bucket_name = self.minio_bucket_name,
            object_name = to_file,
            file_path = from_file
        )
        return from_file
