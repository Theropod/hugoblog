# 有关几种使用python裁剪矢量数据的方式和速度

## 例子：用中国边界裁剪MODIS Collection6火点数据（一年，点，shp）

### 通过QGIS或命令调用ogr2ogr来裁剪Vector都极慢，切一次几十分钟，QGIS自带方法只需几秒
- 根据 http://osgeo-org.1560.x6.nabble.com/gdal-dev-ogr2ogr-clip-operation-very-slow-compared-to-QGIS-td5385612.html, QGIS Native使用的库是GEOS的 https://github.com/libgeos/geos, 在clip之前有intersection test等去除冗余操作而加速。而ogr2ogr没有。  
### 如何使用CEOS加速的clip
1. fiona读入，提取shapely的geometry，循环所有geometry执行intersection，把geometry放回去https://www.hatarilabs.com/ih-en/how-to-clip-polygon-layers-with-python-fiona-and-shapely-tutorial。 
2. 或，使用geopandas>0.7 https://geopandas.org/gallery/plot_clip.html
