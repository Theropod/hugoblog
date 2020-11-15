---
title: 安装Google Cloud SDK遇到的问题和解决
date: 2017-04-09 01:33:27
tags: 
- 谷歌
- 谷歌云平台
categories: 
- 网站相关
---

<!--more-->

想在google cloud platform上部署一个网站来着，按官方的教程要在本地装一个控制的程序，但是一直安装失败。下了一个exe安装包，只装给当前用户的话就会报错说什么ascii code cant decode，装给所有用户的话会说系统找不到指定的路径。改用官方给的zip里的.bat安装也是直接报错。
查了一个晚上，有人说中文路径、文件夹不能有空格、都排除了。把电脑改成英语，去搜那句系统找不到指定的路径-the system cannot find the path specified，也没结果。换了几个zip版本也没用。
最后搜了zip安装的时候报错KeyError: '_convert'发现是python版本问题。在教程不知道哪里其实提过一句这个依赖python2，不是3。于是在系统的path里面加上了python2的路径就能通过zip装了，exe还是不行。
还有，到最后问你要不要把这个东西加到path，选了是之后其实没有加。。。他会提示你自己还得加一遍。比如我把zip解压到了C:\路径，就要在path里加上 C:\路径\bin。这个zip安装的意思就是在解压的zip里运行bat，然后把自己给安装了。
想不通的地方在于，之前的exe安装包是自带2.7的啊，为什么就不让装？
虽然没懂，但是控制台能用gcloud了，不管了。。。