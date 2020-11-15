---
title: 昂达 Onda Obook 20 plus v7 双系统安卓root xposed twrp操作记录
date: 2018-02-01 16:52:43
tags: 
categories: 
- Windows姿势
---

<!--more-->

好像这种国产双系统寨板都是Intel Cherry Trail的主板，（我是Cherry Trail CR，Z8350的U），所以说什么昂达论坛，国外的TechTablets，Xda，Onda Forum，Chuwei Forum都有很多贴可以看，甚至国外的比国内的讲得更好一点（也许是因为我用谷歌搜的，但是百度已经被平板广告污染了，搜不到）。。。也不知道洋人花这么大功夫在这个不值钱的东西上是为了什么
简单的操作流程：
http://www.ondabbs.cn/forum.php?mod=viewthread&tid=73864
https://forum.xda-developers.com/android/development/root-tutorial-intel-atom-cherry-trail-t3468330
https://www.mobile01.com/topicdetail.php?f=163&t=4923924
差不多说的是同样的流程。。。

 - 从论坛上下了一个包含fastboot.exe adb.exe bootimg.exe twrp.img等等的文件夹，又装了一些Intel的刷机工具（装驱动用），下了最新supersu的zip，还有一个论坛dalao找到的American Megatrends支持的双系统平板用xposed(这个寨板的BIOS就是AMI的)
https://forum.xda-developers.com/xposed/lollipop-xposed-framework-intel-cherry-t3565149
 - 首先修改原厂ROM的boot.img。用工具解包，改几个文件中的几句话（据说是boot.img校验?如果能改system分区就不让启动？），改完了打包，得到新的boot.img。
 - 设置-开发人员里面关闭OEM锁，打开USB调试，寨板连电脑，重启选安卓，我是在选择之后立即按住音量-，进入fastboot模式。
 - 电脑cd到fastboot.exe文件夹，执行解锁oem锁，把boot分区刷入新的boot，再用twrp.img启动recovery模式。twrp里面刷supersu
 - 本来这样就行了，结果我开不了机，但能进fastboot，但是我想要把twrp.img刷入recovery分区的时候告诉我找不到。。。failed to get partition recovery not found
 - 算了，直接把新boot.img替换原厂刷机包的boot.img，重新刷安卓。。。再进fastboot就能刷twrp了。。。twrp里面刷了supersu和xposed。重启发现没有问题，再安一个xposed的官方应用，这个安卓van机环境算是弄好了。论坛上有人警告用xposed会有卡到bootloop，我是没遇到，可能我的xposed包是正确的。
因为刚才重新刷了一遍安卓，而原厂安卓刷机包里面有一个GPT.bin，把分区表覆盖了（要是调整两个系统的容量也是改这里，搜索教程有真相），所以我的Windows10重启的时候就识别不出来。。。但是大丈夫，用老毛桃-DiskGenius-重建分区表，如果放efi的那个还是未分配，格式化成fat32之后用引导修复工具就行了

以上这些从查到搞完也就几个小时，很顺利了。真正困扰人的是双系统的windows10不读Class10以上或者64G以上的tf卡\sd卡的问题。我tmd搜了几天，全世界的论坛都看了，还是不行。仅仅是偶尔能看到，一会儿又没了，还差点把我三星的Evo搞坏了。这个好像是寨板通病，光搜我的型号没有什么讨论，但是其他型号的讨论很多。。。
网上的方法总结起来就是，先在重启高级选项里关闭驱动安装的签名，再在设备管理器里面把SD Host Controller驱动换成论坛里提供的，最后再到C:\Windows\System32\Drivers里看一下sdbus.sys和dumpsd.sys的版本，要是没变再手动替换一下。重启之后在BIOS里面可以找到一个Advanced and then System Component，把MS Custom SMbus Driver开或者关，都有可能进windows之后识别
试了无数遍之后发现这个识别不识别也是看运气，论坛里也有人说这个无解，时间长了还是不能稳定，甚至卡都会坏。。。总之我是不试了，寨板还是要配寨卡。