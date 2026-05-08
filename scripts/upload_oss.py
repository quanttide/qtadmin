import os
import sys

import oss2


access_key_id = os.environ.get("ALIYUN_ACCESS_KEY_ID")
access_key_secret = os.environ.get("ALIYUN_ACCESS_KEY_SECRET")

if not access_key_id or not access_key_secret:
    print("Error: ALIYUN_ACCESS_KEY_ID or ALIYUN_ACCESS_KEY_SECRET not set")
    sys.exit(1)

auth = oss2.Auth(access_key_id, access_key_secret)
bucket = oss2.Bucket(auth, "oss-cn-hangzhou.aliyuncs.com", "qtadmin-studio")

local_dir = "build/web"
for root, dirs, files in os.walk(local_dir):
    for file in files:
        local_path = os.path.join(root, file)
        oss_path = os.path.relpath(local_path, local_dir).replace(os.sep, "/")
        bucket.put_object_from_file(oss_path, local_path)
        print(f"Uploaded: {oss_path}")

print("Done!")
