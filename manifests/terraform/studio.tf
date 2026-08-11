# qtadmin studio 客户端发布分发桶（IaC）
#
# 桶 qtadmin-studio：命名对齐站点规范 {repo}-{type}（如 qtclass-studio / qtdata-studio）。
# 产物：Flutter Web 版（index.html + flutter_bootstrap.js）。
# 静态网站托管：Web 版作为默认首页（admin.quanttide.com 根路径）。
# 部署流水线：.github/workflows/deploy-studio.yml（tag 触发 → flutter build → ossutil cp → 刷新 CDN）。

resource "alicloud_oss_bucket" "studio" {
  bucket = "qtadmin-studio"

  # 静态网站托管（Web 版入口 index.html）
  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}

# 2023 后新桶默认开启"阻止公共访问"，会使 public-read 失效（AccessDenied），
# 需显式关闭（手动部署时曾遇此问题，见 qtcloud manifests/terraform/studio.tf）
resource "alicloud_oss_bucket_public_access_block" "studio" {
  bucket              = alicloud_oss_bucket.studio.bucket
  block_public_access = false
}

# 公共读：客户端分发下载；如后续接入 CDN 回源鉴权可改回 private
resource "alicloud_oss_bucket_acl" "studio" {
  bucket = alicloud_oss_bucket.studio.bucket
  acl    = "public-read"
}
