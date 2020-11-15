---
title: IDL调用MRT批处理MODIS
date: 2016-10-09 03:26:54
tags: 
- IDL
categories: 
- GIS
---

<!--more-->

IDL调用MRT批处理MODIS产品
----------
我能说为了在IDL里批量拼接MODIS我查和试了有20个小时吗？
总之就是envi自己的函数都不怎么样。。。调用envi的seamless mosaic看起来不错，帮助里说现在都用envi::openraster和ENVIMosaicRaster。
然而前者打不开hdf4，只有在envi里手动选；后者又要求输入必须是object reference，但用老的ENVI_OPEN_DATA_FILE或者HDF_SD_GETDATA都得不到object reference。
最终的结果还是IDL里面调用MRT。官方的还是最好。
代码：[来自某博客](http://blog.sina.com.cn/s/blog_942ff76e0102wgrk.html) 
真的比我不知道高到哪里去了。更加认清了我菜逼的本质。
