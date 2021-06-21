---
title: "Pycsw为何请求maxrecords无效"
date: 2020-12-23T10:02:52+08:00
draft: false
categories:
- 网管
tags:
- pycsw
- 毕业用
---
因为需要在pycsw的服务端设置（默认是default.cfg）server.maxrecords
pycsw-admin.py -c load_records -f default.cfg -p /root/glass-xml/DSR
python ./pycsw/wsgi.py
服务器上的设置脚本
