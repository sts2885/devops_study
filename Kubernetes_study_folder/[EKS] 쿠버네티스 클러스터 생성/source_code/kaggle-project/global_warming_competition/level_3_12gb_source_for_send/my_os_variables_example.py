import os 
os.environ['minio_url'] = "s3.amazonaws.com"# if using s3, not minio server
os.environ['minio_access_key'] = "access_KEY_for_s3_or_minio_id"
os.environ['minio_secret_key'] = "secret_key_for_s3_or_minio_pass"
os.environ['minio_region'] = "us-east-1"
os.environ['minio_bucket_name'] = "your-bucket-name"

os.environ['competition_name'] = "google-research-identify-contrails-reduce-global-warming"

os.environ['kaggle_access_key'] = "from-your-kaggle-api"
os.environ['kaggle_secret_key'] = "from-your-kaggle-api"

#os.environ['pv_mount_name'] = '/PVS/pv_'
os.environ['pv_mount_name'] = './global_warming_'
os.environ['pv_count'] = '20'

os.environ['download_from'] = 's3'#'kaggle'