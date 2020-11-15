---
title: 使用Openlayers v4时感觉需要记一下的东西
date: 2017-03-06 20:21:50
tags: 
- openlayers
categories: 
- GIS
---

<!--more-->

 - ol.map有一个forEachFeatureAtPixel的函数，可以用来响应鼠标事件，得到feature的属性。但是对于TileWMS的source，或者说用这个source的Layer，这个函数没起作用。没有看源码，估计是因为WMS图层通过http请求tile来生成地图，而这个函数不包含这种方法。官方的示例用getGetFeatureInfoUrl代替，得到的是服务器返回的一个html元素。
 - 接着上一条，getGetFeatureInfoUrl里有一个INFO_FORMAT的参数，一直以为是openlayers提供的，其实它是geoserver定义的，是发的请求里的一个参数。