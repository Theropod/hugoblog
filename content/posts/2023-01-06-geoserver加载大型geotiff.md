---
title: "Geoserver加载大型geotiff"
date: 2023-01-07T06:23:59+08:00
draft: false
categories:
- 各种姿势
tags:
- Geoserver
- gdal
- gis
---
## 背景
希望用geoserver提供大量栅格的wms服务。例如3000+个2MB以内的小geotiff，代表了美国的精细人口密度,分辨率30米。
## 大规模文件的处理方式
以下内容主要参考[这个workshop的材料:](https://github.com/planetfederal/workshops/blob/master/workshops/data_configs/sphinx/source/raster.rst)  
### 三种可能的处理方式
- 单tif文件, 文件可能有inner tiles和/或overview
- 多个tile
- 金字塔

如何选择处理方式？主要和数据量大小有关
- 如果数据小于1-2GB，基本推荐单tif文件，但需要优化并且有合适的内部tile和overview。
- 大于2GB的数据需要分成小文件，同时建立内部的金字塔和tile。
- 如果文件特大、且需要再各个缩放层级使用，则需要使用外部的金字塔。

## 处理相关知识
### 文件格式
一般都使用tif，因为tif能够以tile形式组织内部数据，在显示部分图像内容时，可以直接读取某个范围，而PNG/JPEG文件都必须读取整张图片。同时，tiff可以存储一些低分辨率的overview。
### 什么是overview
每个tif文件的band有0到多个overview，提供低分辨率的缩略图。大小不同但地理范围相同。[参见此处](https://gdal.org/user/raster_data_model.html#overviews)
### tiling和金字塔

### 如何优化tif文件
- 如何生成overview
- 使用tile方式
- 使用何种压缩方式
经过测试，使用LZW压缩，最后缩小了很多（本地例子）
### 方法1 
直接build vrt，之后可以用gdaltranslate转换成tiff.
### 方法2
geoserver安装image mosaic的插件。此种方法适用于单个文件太大（压缩后还是20-30GB以上，影响读取速度）或者要同时加载多个时间、波段的文件时。

其他优化  
JAI
