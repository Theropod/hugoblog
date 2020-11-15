# Python极低阶学习中的一点经验


<!--more-->

 - 关于一些包的安装。我是一般用vscode写，那个里面的终端简直有毒，不怎么支持中文而且pip的更新、安装其它的包基本失败。。。最终还是在cmd下弄好，浪费了不少时间。需要注意的一点就是cmd里面是直接输pip，而不是在python下进pip
 - 这次要装一个pyModis的包，它有GDAL的一个依赖，但是pip的时候就疯狂报错安不上。这些包的官网总是告诉你要去编译binary到你的平台，但我还不能熟练完成。。。后来找到[Python Extension Packages for Windows - Christoph Gohlke这个网站](http://www.lfd.uci.edu/~gohlke/pythonlibs/#gdal)，是各种windows下编译的python的科学的包的宝库。。。里面下了gdal.whl（whl就是包的压缩格式而已），pip install 了wheel来支持它，然后cd进下载目录pip install xxx.whl就安上了。至于其它的办法，弄半天没有一步不出错的。。。反正我是会了一个了，再也不会碰别的了。
