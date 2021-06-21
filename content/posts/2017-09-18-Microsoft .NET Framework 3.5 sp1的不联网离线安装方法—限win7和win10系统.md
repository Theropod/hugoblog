---
title: Microsoft .NET Framework 3.5 sp1的不联网离线安装方法—限win7和win10系统
date: 2017-09-18 17:23:05
tags: 
- arcgis
categories: 
- 各种姿势
---

<!--more-->

装Arcgis又遇到了，记录一下
[一个转载](http://blog.sina.com.cn/s/blog_5f1077ed0102wlnp.html)
下载了​系统安装镜像后，又可分为两种方法来安装这个功能，原理都是一样的。具体如下

1.​下载的镜像一般为ISO模式，用虚拟光驱打开镜像，会产生一个虚拟盘符，比如是E。此时win7系统直接点击开始—所有程序—附件—命令提示符。注意：这里打开命令提示符的时候，需要右键，选择以管理员身份运行。否则输入的命令会提示没有权限！！！

​2.打开传说中的命令提示符，下一步就要输入传说中非常厉害的命令：

这里千万千万要注意​，每一个斜杠“/”和前面的命令前必须有空格，不然绝对会出错。

dism.exe /online /enable-feature /featurename:NetFX3 /Source:h:\sources\sxs​

下面解释下这个命令：​

①DISM.exe是部署映像服务和管理 ，会装载服务所用的 Windows 映像 (.wim) 文件或虚拟硬盘驱动器（.vhd 或 .vhdx）；②dism.exe /online 表示 以正在运行的操作系统为目标；​③​dism.exe /online /enable-feature表示启用映像中的特定功能；④dism.exe /online /enable-feature /featurename:NetFX3 表示指定功能名称为NetFX3，这里注意，功能名称区分大小写，一定要确定。其他地方是不区分大小写的。⑤dism.exe /online /enable-feature /featurename:NetFX3 /Source:h:\sources\sxs​，这里表示指定了功能安装包所在的盘符。

既然系统加载到了刚刚的E盘符。后面的“/Source:h:\sources\sxs”​，这里就需要讲"h"改为“e”,不区分大小写哦！其他千万不要改动！！

3.​点击enter键盘，坐看进度条慢慢达到100%，就是这个feel，超爽的feel，娃哈哈。

