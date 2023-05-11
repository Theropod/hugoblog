# Geoserver中netcdf+wms/wcs/wps

> 使用Geoserver支持netcdf文件的展示、获取和分析，需要安装插件。  
> 主要参考的链接：[geoserver](https://docs.geoserver.org/latest/en/user/community/ncwms/index.html) [geosolutions](https://geoserver.geo-solutions.it/multidim/multidim/netcdf/netcdf_config.html)

## 需求
- 系统有NetCDF-C环境
- 需要安装插件  
  - geoserver-x.xx.x-netcdf-out-plugin.zip  
  NetCDF Output Format，允许以NetCDF格式下载多维WCS结果。[地址](https://geoserver-pdf.readthedocs.io/en/latest/extensions/netcdf-out/index.html)  
  - geoserver-x.xx.x-netcdf-plugin.zip  
  NetCDF插件，允许在geoserver data store中加入NetCDF的数据源。[地址](https://geoserver-pdf.readthedocs.io/en/latest/extensions/netcdf/netcdf.html)
  - geoserver-x.xx.x-wps-plugin.zip  
  WPS插件，开启WPS功能。[地址](https://docs.geoserver.org/master/en/user/services/wps/index.html)   
  - geoserver-x.xx.x-colormap-plugin.zip  
  Dynamic colormap generation，用于ncwms的颜色列表动态生成。[地址](https://docs.geoserver.org/latest/en/user/community/colormap/index.html#community-colormap)    
  - geoserver-x.xx.x-ncwms-plugin.zip  
  可以实现部分ncWMS软件的功能：动态调色板（手动加入一个Dynamic palette style颜色列表，自动根据数据的值生成其对应该列表颜色的SLD），GetMap请求中指定Color相关的参数、GetTimeSeries操作。ncWMS本身可以在tomcat里运行，也可以作为插件在geoserver里运行。[地址](https://docs.geoserver.org/latest/en/user/community/ncwms/index.html)  

  下载位置在这里找：geoserver官网release里面的extension，或build里面的community和extension
- 注意插件要和自己的geoserver版本一致

## WMS
- 新建datasource的时候就可以用了，但是注意它只能支持dimensional的

## WCS
- 若WMS能用，WCS也能，但是这个需要我们

## WPS
- 根据geoserver的定义写一个功能的class，生成jar放到``目录下，geoserver就可以识别。
- geoserver有request builder可以在填参数、自动生成
- 如何写的教程网址是
- 一个调用NCL的例子，在Github上传了。

