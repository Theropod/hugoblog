# 关于openlaeyrs获取谷歌卫星地图的无偏瓦片


<!--more-->

更新：好像谷歌地图的瓦片地址khm3这个一直在变化啊，近来变成khm0了，自己也得跟着变化。。。
还有，这两天发现天地图自己的标注和无偏googlemap居然是重合的，结果我国内版的谷歌瓦片对应不上天地图的标注了。。。他们自己都不用火星坐标系的吗？

---
谷歌地图的卫星影像在国内是偏移的，比如国内能访问的那个http://www.google.cn/maps，还有Google Map API上专门提供给中国的http://maps.google.cn/maps/api/的这两个都是偏移过的，而https://www.google.com/maps/,以及https://maps.googleapis.com/maps/api就是没有偏移的。
一个验证：
中国版的地图
![这里写图片描述](http://img.blog.csdn.net/20170526224429416?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvVGhlcm9wb2Q=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
同一x/y/缩放级别下的国外版的地图
![这里写图片描述](http://img.blog.csdn.net/20170526224614043?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvVGhlcm9wb2Q=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
从资源里面找到同一个xyz的瓦片看一下
中国的
![这里写图片描述](http://img.blog.csdn.net/20170526224725592?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvVGhlcm9wb2Q=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
国外的
![这里写图片描述](http://img.blog.csdn.net/20170526224819828?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvVGhlcm9wb2Q=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
可以发现两点：

 1. 请求瓦片的时候，发送的是Web Mercator下地图显示中心的经纬度结合瓦片的长宽算出的一个值。请求国内/国外的地址，发回的对应的瓦片就是偏移/未偏移的。
 2. 道路图层听说是国内哪家合作提供的，因此和偏移过的瓦片是重合的。

由于我这边是想和影像做一些叠加，所以坐标必须是无偏的。看了一下国外的访问地址是https://khms3.google.com/kh/v=726?x=28415&y=11580&z=15
这个v有人猜测是版本号，我也不知道。。。改了一下openlayers的瓦片获取程序，感觉偏移基本没了。
而网上比较流行的一个地址是http://mt1.google.cn/maps/vt，要有一个layers是s@110，这个就有偏了。。。但是和国内的服务都是契合的
稍微改一下openlayers获取瓦片的class，url就是https://khm3.google.com/kh
```
OpenLayers.Layer.GoogleLayer2 = OpenLayers.Class(OpenLayers.Layer.XYZ, {
    url: null,
    tileOrigin: null,
    tileSize: new OpenLayers.Size(256, 256),
    type: 'png',
    useScales: false,
    overrideDPI: false,
    initialize: function(name, url, options) {
        this.v = options.v;
        OpenLayers.Layer.XYZ.prototype.initialize.apply(this, arguments);
    },
    getURL: function(bounds) {
        var res = this.getResolution();
        var originTileX = (this.tileOrigin.lon + (res * this.tileSize.w / 2));
        var originTileY = (this.tileOrigin.lat - (res * this.tileSize.h / 2));
        var center = bounds.getCenterLonLat();
        var x = (Math.round(Math.abs((center.lon - originTileX) / (res * this.tileSize.w))));
        var y = (Math.round(Math.abs((originTileY - center.lat) / (res * this.tileSize.h))));
        var z = this.map.getZoom();
        var url = this.url;
        var s = '' + x + y + z;
        if (OpenLayers.Util.isArray(url)) {
            url = this.selectUrl(s, url);
        }
        url = url + '/v=${v}&?&x=${x}&y=${y}&z=${z}'; //&L=4&X=12&Y=3
        url = OpenLayers.String.format(url, { 'v': this.v, 'x': x, 'y': y, 'z': z });
        return OpenLayers.Util.urlAppend(
            url, OpenLayers.Util.getParameterString(this.params)
        );
    },

    CLASS_NAME: 'OpenLayers.Layer.GoogleLayer2'
});
```
几个参考：http://blog.csdn.net/aliqing777/article/details/9818985
http://www.sosaw.com/threads-296984-1-1.html
https://stackoverflow.com/questions/7200682/why-have-these-google-satellite-map-tile-links-stopped-working
