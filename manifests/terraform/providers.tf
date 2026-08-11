terraform {
  required_version = ">= 1.5"

  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1.240"
    }
  }
}

# 阿里云凭证通过环境变量注入（不在代码中写死）：
#   export ALICLOUD_ACCESS_KEY=...
#   export ALICLOUD_SECRET_KEY=...
provider "alicloud" {
  region = var.region
}

# 远程状态：OSS（本机与 CI 共用，CI 必须持久化状态）。初始化时通过 -backend-config 指定：
#   terraform init \
#     -backend-config="bucket=quanttide-terraform-state" \
#     -backend-config="key=qtadmin/terraform.tfstate" \
#     -backend-config="region=cn-hangzhou"
terraform {
  backend "oss" {}
}
