terraform {
  required_version = ">= 1.0"

  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1.212"
    }
  }
}

provider "alicloud" {
  region = var.region
}

resource "alicloud_oss_bucket" "website" {
  bucket = var.bucket_name

  versioning {
    status = "Enabled"
  }

  website {
    index_document = var.index_document
    error_document = var.error_document
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "alicloud_alidns_record" "admin_cname" {
  domain_name = "quanttide.com"
  type        = "CNAME"
  rr          = "admin"
  value       = "${alicloud_oss_bucket.website.bucket}.${alicloud_oss_bucket.website.extranet_endpoint}"
  ttl         = 600
  status      = "ENABLE"

  depends_on = [alicloud_oss_bucket.website]
}
