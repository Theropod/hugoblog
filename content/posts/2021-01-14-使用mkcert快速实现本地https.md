---
title: "2021 01 14 使用mkcert快速实现本地https"
date: 2021-01-14T15:17:54+08:00
draft: false
---
### 安装
直接使用github上发布的binary（因为是go写的），或者使用brew/chocolatey等安装
### 使用
- `mkcert --install` 直接默认生成一个，安装到local trust store
- `mkcert example.com "*.example.com" example.test localhost 127.0.0.1 ::1` 给这些名称创建certificate，提示生成路径，需要手动安装
- 若要将此cert用在局域网，在签发证书时加上本机的局域网ip，拿到证书文件手动安装。
- 找证书的路径：`mkcert -CAROOT`
- 还有高级用法，详见项目文档。