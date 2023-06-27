#키를 이렇게 코드에 추가하기 싫으면
#리눅스 기반 시스템에서는
#export AWS_ACCESS_KEY_ID="keykeykey"
#export AWS_SECRET_ACCESS_KEY="KEYKEYKEY"
#터미널에서 입력해 두면 된다.
#나는 윈도우라 provider.tf에 넣고, 해당파일은
# .gitignore에 넣었다.

/*


#노트북에서는 이거 있어야 돌아가더라 local 에 common tags가 없다고
locals {
  date        = "2023.05.16"
  common_tags = {
    group   = "sts"
    created = local.date
  }
}

provider "aws" {
    region = "us-east-1"

    access_key = "your_access_key"
    secret_key = "your_secret_key"

    default_tags{
        tags = local.common_tags
    }
}

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
}
*/