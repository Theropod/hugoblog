---
title: 操作记录-在leaflet中加速大量geojson/topojson多边形的显示
date: 2019-01-06 20:28:12
tags: 
- Leaflet
- Geojson
- mapbox
- protobuf
categories: 
- GIS
- WEB相关
---

<!--more-->

### 场景
需要展示覆盖北京的25万+个规则的网格，进行常规的点击显示数据、绘制勾选、着色等等操作。但是希望能直接使用geojson/topojson（原来构想的是随机森林和pagerank跑出结果，匹配到多边形，实时输出到geojson），不转格式，同时想尝试后端越少越好。。。
### 实现
- 首先想到的自然是类似于geojson-vt的实现，将json转换成切片之后显示。实际用了leaflet.vectorGrid.js，为了节省空间把geojson先转成topojson，体积大概小了30%，之后直接作为图层放到map里面。这样交互倒是很好实现，但是速度很慢。计时出来，下载70M的topojson需要几秒，而后计算切片显示又需要好几秒。。。最开始我还弱智地把topojson再在前端转成了geojson来放进slicer，就更慢了。另外，在放大到很大的时候自然性能还行，但是缩小到12级往下，缩放/拖动都需要重新计算，查看的延迟太大，不能正常使用。
-  首先就是要简化数据，使用了几种北京的建成区遥感分类结果，最后挑选了最新的一个结果来进行叠加，（具体就是先区域统计再筛选，不知道有没有更快的办法）直接缩小到6万+，geojson缩小到17M。这样的话直接用vectorGrid，除了缩小之外甚至都不会有延迟了，但是这里还是必须先把整个json下载下来。
- 为了不在一开始就下载所有的json，想到用一个简单的后端。方案是先用tippecannoe把geojson转成mapbox的mbtiles标准（等于把一个geojson转成一个sqlite的文件数据库）。leaflet.VectorGrid里可以把数据源选择成protobuf(protocol buffer)，而mbtiles被发布成http://{host}:{port}/layer/{z}/{x}/{y}.pbf这样的buffer，流程上就ok了。github上面mbtiles有无数种通过自己来发布服务的办法，都是基于mapbox官方发布到github的几个基于node.js的插件来组合的，我选了一个比较无脑的tilehut.js。但是貌似mapbox的sqlite依赖给的有问题，我被卡住了一天，github issue里很多讨论，但是都没有用。。。最后记得是执行了重建所有packages依赖的一类操作才安装上。
这套方案和mapbox正常显示地图是一样的，所以响应上和底图一样基本没有延迟，缩小后也不会卡顿，定义样式和事件都可以。其实直接把mbtiles上传到mapbox也可以用，只不过不太好自动化进行而已。

总之，以上的操作证明了即便是大规模的数据，也可以只使用geojson来做地图展示，这样对于数据生成的步骤方便了不少。
### 一个protobuf例子
值得注意的几点：指定颜色的时候需要首先声明fill:true，另外由于样式化是针对protobuf里的所有图层分别设置的，所以要搞清图层的名字究竟是什么（尤其是和文件名不一致时）
```
// beijing grids color definition
function getColor_People(d) {
	return d > 10000
		? "#800026"
		: d > 5000
		? "#BD0026"
		: d > 2500
		? "#E31A1C"
		: d > 1000
		? "#FC4E2A"
		: d > 500
		? "#FD8D3C"
		: d > 200
		? "#FEB24C"
		: d > 50
		? "#FED976"
		: "#FFEDA0";
}

var gridLayer;
var previousGridId = null;
var gridPopup = L.popup({ maxWidth: 1500, maxHeight: 400 });
// load grid with pbf tiles
var gridLayer = L.vectorGrid.protobuf(
	 "{host}:{port}/layer/{z}/{x}/{y}.pbf",
	{
		// pane: "gridPane",
		rendererFactory: L.canvas.tile,
		attribution: "© Your Organization",
		interactive: true,
		getFeatureId: function(feature) {
			return feature.properties.id;
		},
		vectorTileLayerStyles: {
			mylayername: function(feature) {
				return {
					// fill: true is needed
					fill: true,
					fillColor: getColor_People(feature.people),
					fillOpacity: 0.7,
					stroke: false,
					color: "#595959",
					weight: 0.6
				};
			}
		}
	}
);
gridLayer.on("click", function(e) {
	if (map.getZoom() < 14) {
	} else {
		//console.log(e);
		var prop = e.layer.properties;
		//var latlng = [Number(parcel.y), Number(parcel.x)];
		var latlng = e.latlng;
		// settimeout otherwise when map click fires it will override this color change
		// clear selection if slect on the same grid
		var selectedGridId = prop["fnid"];
		gridLayer.resetFeatureStyle(previousGridId);
		if (selectedGridId === previousGridId && !gridPopup.isOpen()) {
			gridPopup.remove();
			selectedGridId = null;
		} else {
			gridPopup
				.setLatLng(latlng)
				.setContent(JSON.stringify(prop))
				.openOn(map);
			gridPopup.bringToFront();
			map.panTo(latlng);
			setTimeout(function() {
				gridLayer.setFeatureStyle(
					selectedGridId,
					{
						color: "red"
					},
					100
				);
			});
		}
		previousGridId = selectedGridId;
	}
});
// gridLayer legends
var gridLayerLegend = L.control({ position: "bottomright" });
gridLayerLegend.onAdd = function(map) {
	var div = L.DomUtil.create("div", "info legend"),
		grades = [50, 200, 500, 1000, 2500, 5000, 10000],
		labels = ['人流量'];
	div.innerHTML+='<h4>人流量</h4>';
	// loop through our density intervals and generate a label with a colored square for each interval
	for (var i = 0; i < grades.length; i++) {
		div.innerHTML +=
			'<i style="background:' +
			getColor_People(grades[i] + 1) +
			'"></i> ' +
			grades[i] +
			(grades[i + 1] ? "&ndash;" + grades[i + 1] + "<br>" : "+");
	}

	return div;
};
// evnets to fire when adding and removing overlays
map.on("overlayadd", function(e) {
	switch (e.name) {
		case "Grid人流量":
			gridLayerLegend.addTo(map);
			break;
		case "Grid2":
			gridLayer2Legend.addTo(map);
			break;
		default:
			break;
	}
});
map.on("overlayremove", function(e) {
	switch (e.name) {
		case "Grid人流量":
			gridLayerLegend.remove();
			break;
		case "Grid2":
			gridLayer2Legend.remove();
			break;
		default:
			break;
	}
});
/**
 * LAYER CONTROLS
 */
var baseMaps = {
	BingSatellite: bingLayer,
	OSM: osmTile,
	GaoDe: GaoDeTile,
	Grayscale: mapBoxTile
};
var overlayMaps = {
	Grid人流量: gridLayer,
};
var layerControl = L.control.layers(baseMaps, overlayMaps).addTo(map);
```
效果：![在这里插入图片描述](https://img-blog.csdnimg.cn/20190106202239504.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L1RoZXJvcG9k,size_16,color_FFFFFF,t_70)
