# Geoserver的CORS问题解决


<!--more-->

这已经是第四次了，每次都不太能记住
--

 - Geoserver默认CORS是关的，所以读发布的地图中的数据和提交给geoserver数据的时候会有CORS错误。做两个事情：

----------
1.  到geoserver目录下的webapps/geoserver/WEB-INF/web.xml里把两处cors的filter打开（有提示，uncomment to enable CORS）
2.  这时重启geoserver会报错找不到 org.eclipse.jetty.servlets.CrossOriginFilter。因此到[这里](http://repo1.maven.org/maven2/org/eclipse/jetty/jettyservlets/9.2.13.v20150730/%20%E4%B8%80%E4%B8%AA%E5%9C%B0%E5%9D%80)下载jetty-servlets-9.2.13.v20150730.jar（根据其他的jar的版本找的版本），放到GeoServer 2.11.2\webapps\geoserver\WEB-INF\lib里面。
