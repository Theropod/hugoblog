# Geoserver中netcdf的wms wcs和wps

> Geoserver支持netcdf文件的展示、获取和分析，但是需要安装插件。
> 主要参考的链接：

## 需要的插件
- 列表
- 下载位置在这里找：
- 注意要和自己的geoserver版本一致

## WMS
- 新建datasource的时候就可以用了，但是注意它只能支持dimensional的

## WCS
- 若WMS能用，WCS也能，但是这个需要我们

## WPS
- 根据geoserver的定义写一个功能的class，生成jar放到``目录下，geoserver就可以识别。
- geoserver有request builder可以在填参数、自动生成
- 如何写的教程网址是
- 一个调用NCL的例子，在Github上传了。

