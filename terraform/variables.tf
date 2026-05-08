variable "region" {
  description = "Aliyun OSS region"
  type        = string
  default     = "cn-hangzhou"
}

variable "bucket_name" {
  description = "OSS bucket name"
  type        = string
  default     = "qtadmin-studio"
}

variable "domain_name" {
  description = "Custom domain for the website"
  type        = string
  default     = "admin.quanttide.com"
}

variable "index_document" {
  description = "Index document for static website hosting"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Error document for static website hosting"
  type        = string
  default     = "index.html"
}
