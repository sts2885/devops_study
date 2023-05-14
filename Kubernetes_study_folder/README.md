#키를 이렇게 코드에 추가하기 싫으면
#export AWS_ACCESS_KEY_ID="keykeykey"
#export AWS_SECRET_ACCESS_KEY="KEYKEYKEY"
#터미널에서 입력해 두면 됨.
#깃허브에 올릴거니까 키를 export 해두자.
#이거 보니깤ㅋㅋ 리눅스계열만 되나본데?
#그럼 이 파일을 ignore해야 됨.

provider "aws" {
    region = "us-east-1"
    profile = "ts_junior01"

    access_key = "AKIATHOTITFUIX3ENWEK"
    secret_key = "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"
}

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
}