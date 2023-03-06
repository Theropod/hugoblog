---
title: "Geoserver加载大文件"
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
本文主要参考[这个workshop](https://github.com/planetfederal/workshops/blob/master/workshops/data_configs/sphinx/source/raster.rst)，辅以搜索到的各类教程。

## 相关知识
此处也参考了这个[官方文档](https://docs.geoserver.geo-solutions.it/edu/en/enterprise/raster.html#deciding-when-to-go-beyond-and-use-mosaicking-plugins)
### 目标
主要目标有两个：
1. 快速获取数据子集：主要涉及re-tiling和compression
2. 任意分辨率快速获取数据：主要涉及overviews或建立低分辨率的数据版本
### 一般使用的文件格式
一般都使用tif，因为tif能够以内部的tile形式组织内部数据，在显示部分图像内容时，可以直接读取某个范围，而PNG/JPEG文件都必须读取整张图片。同时，tiff可以存储一些低分辨率的overview。
### 什么是overview
每个tif文件的band有0到多个overview，提供低分辨率的缩略图。大小不同但地理范围相同。[参见此处](https://gdal.org/user/raster_data_model.html#overviews)
### 如何选择tiling和金字塔参数
显然，金字塔的tile size过小或过大都会影响性能。据workshop说，理想的size是0.5-1GB，这样既容易管理且减少了tiles的数量。需要注意的是，inner tile和金字塔的分割不冲突，内部的tiling总是会提高性能。Tiling的示意可以参考这个[教程](https://docs.geoserver.geo-solutions.it/edu/en/wcs/compression_tiling.html)。  
另外，金字塔级数$n = \log_2(\frac{width}{tile\_width})$
### 压缩方式  
主要是LZW、Deflate、ZSTD（无损）和LERC、JPEG（有损）。LZW压缩适合重复多的数据（如类别数据），[有人测试过](https://kokoalberti.com/articles/geotiff-compression-optimization-guide/)，LZW、ZSTD、Deflate压缩率差别不大，但合理使用压缩时的Predictor参数对结果有提升。ZSTD读取最快。我用前述的人口数据测试zstd确实减小了很多体积。
### 其他需要注意
- 根据数据类型选择合适的重采样方式，例如NN不适合图像类数据，但适合非图像类（如高程）和分类数据
- 提前重投影到需要的CRS
- 可以使用调色板来减少RGB影像数据量，如使用`rgb2pct image3.tiff image3p.tiff`
- 多光谱、高光谱的波段存储方式，比如注意应该选择像素交错还是波段交错等。


## 三种可能的处理方式
1. 单tif文件，内部tiling+overview+compression
2. 多个tile的mosaic，辅以内部优化
3. 构建金字塔，辅以内部优化

如何选择处理方式？主要和数据量大小有关
1. 如果数据小于1-2GB，基本推荐单tif文件，但需要优化并且生成合适的内部tile和overview。
2. 大于2GB的数据需要分成小文件，同时建立内部的金字塔和tile。
3. 如果文件特大、且需要再各个缩放层级使用，则需要使用外部的金字塔。

### 方法1 单tif文件
直接build vrt，之后可以用gdaltranslate转换成tiff，并用gdalado生成overview。  
具体参数命令见[此博客](http://cliffpatterson.ca/blog/2017/10/12/processing-high-resolution-imagery-for-geoserver/)和[官方示例](https://docs.geoserver.geo-solutions.it/edu/en/raster_data/advanced_gdal/example1.html)  
#### 使用参考：
- 如何生成overview：  
[overview级别计算](https://gis.stackexchange.com/questions/368560/understanding-what-levels-to-use-in-gdaladdo) 据说边长n倍就是n级别
- gdal的tif处理命令示例[官方文档](https://docs.geoserver.geo-solutions.it/edu/en/raster_data/processing.html#gdal-translate)  
包括gdalinfo、gdal_translate、gdaladdo、Process in bulk、gdalwarp、gdalbuildvrt、gdal_rasterize、gdal_merge.py、gdal2tiles.py、gdal_calc.py、gdal_edit.py
- 设置压缩参数  
gdalado中各个压缩方式参数如何设置[官方文档](https://gdal.org/programs/gdaladdo.html#external-overviews-in-geotiff-format)
- 如何测试性能  
在培训资料里给了一个jmeter测试脚本，修改就可以用。[参见此处](https://docs.geoserver.geo-solutions.it/edu/en/enterprise/raster.html#test-the-unoptimized-mosaic)

### 方法2 生成mosaic
geoserver可以直接安装image mosaic的插件，但性能受限，仍需要优化[(参考此回答)](https://gis.stackexchange.com/a/268648)。 我实际比较过前述的人口数据在geoserver中的使用情况，确实mosaic最慢。  
但如果转换成单个文件后太大（压缩完还是20-30GB以上，影响读取速度）或者要同时加载多个时间、波段的文件时，则不得不使用此方法。

### 方法3 金字塔
金字塔的每个mosaic都存储在一个单独的文件中，虽然有合成时的开销但可以加快图像处理，因为每个overview都是tiled。（与单GEOTIFF不同，其基本级别都可以tile，但overview不会）  
#### 使用参考：
- 使用gdal_retile.py来生成金字塔，并在geoserver使用image pyramid插件。说明和简要步骤见[官方示例](https://docs.geoserver.org/stable/en/user/tutorials/imagepyramid/imagepyramid.html)  
- 图层发布步骤、发布设置、gdal_retile.py使用、USE_JAI_IMAGEREAD设置的[官方教程](https://docs.geoserver.geo-solutions.it/edu/en/raster_data/mosaic_pyramid.html)


## 三种方法外的其他优化
(还是参考了workshop的内容)  
### JAI设置
Geoserver使用JAI(Java Advanced Imaging)读取影像。可以调整的设置有
- Memory capacity和Memory threshold，与TileCache相关
- TileThreads 经验是使用CPU核心数量的2倍的线程做Tile Calculation
- Tile Recycling 只在内存足够时启用这个功能
### Coverage Access设置
调整Geoserver如何使用多线程，对于打开mosaic最重要。主要调整
- Core Pool Size 执行线程池的大小
- Maximum Pool Size 还可以用上面的经验，设置为CPU核心数量的2倍的线程
- ImageIO Cache Memory Threshold 对于WMS不重要，但是对于WCS的大数据量来说，此设置影响缓存到磁盘而不是内存的阈值
### 重投影设置
`-Dorg.geotools.referencing.resampleTolerance` 设置重投影的错误范围，默认0.333，数字越大投影错误越多性能越好，注意调太大了和矢量数据一起显示时可能会出问题。
