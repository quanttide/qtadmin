#!/usr/bin/env python3
"""绑定 admin.quanttide.com 的 CDN HTTPS 证书（泛域名证书 *.quanttide.com）。"""
import json
import os
import subprocess

CERT_DIR = '/home/iguo/.acme.sh/*.quanttide.com_ecc'
DOMAIN = 'admin.quanttide.com'

with open(f'{CERT_DIR}/fullchain.cer') as f:
    pub = f.read()
with open(f'{CERT_DIR}/*.quanttide.com.key') as f:
    pri = f.read()

cert_name = f'cert-{DOMAIN}-{os.popen("date +%s").read().strip()}'
r = subprocess.run([
    'aliyun', 'cdn', 'SetCdnDomainSSLCertificate',
    '--DomainName', DOMAIN,
    '--CertName', cert_name,
    '--CertType', 'upload',
    '--SSLProtocol', 'on',
    '--SSLPub', pub,
    '--SSLPri', pri,
], capture_output=True, text=True)
print('STDOUT:', r.stdout)
print('STDERR:', r.stderr)
print('RC:', r.returncode)
