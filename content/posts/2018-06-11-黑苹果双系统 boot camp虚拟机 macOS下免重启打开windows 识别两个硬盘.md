---
title: 黑苹果双系统 boot camp虚拟机 macOS下免重启打开windows 识别两个硬盘
date: 2018-06-11 15:05:47
tags: 
- 黑苹果
- 虚拟机
categories: 
- 各种姿势
---

<!--more-->

 - 笔记本是256的SSD加上1T的HDD，SSD上win和mac，HDD存数据
 - 其实这一切的起因是想在high sierra下读取ntfs，用的mounty有时能用有时不能用，tuxera和paragon的破解又找不到，非常痛苦。所以想到装一个虚拟机，这样正好office等等软件也不用两边都装了。
 - 现在用的是vmware fusion（xclient上最新版破解也比较好找），除了双硬盘需要手动用一个命令行工具设置之外没有什么问题。也是以boot camp形式导入的已经安装的windows。[这是教程](https://communities.vmware.com/thread/337466)
这个有一个问题，他写的路径是`./Desktop`，但是现在苹果好像已经不是这样写了，而应该是`～/Desktop`
总结一下就是：
 1. 先在导入的windows虚拟机的设置里建一个第二硬盘，起个名字，容量不用管，是不是非得IDE模式我没试
 2.  终端里`diskutil list`看一下要导入哪个盘，如/dev/disk2
 3. `/Applications/VMware\ Fusion.app/Contents/Library/vmware-rawdiskCreator print /dev/disk2` 输出一下刚才看的盘的信息看看对不对
 4. `/Applications/VMware\ Fusion.app/Contents/Library/vmware-rawdiskCreator create /dev/disk2 fullDevice ~/Desktop/MyHDD ide`  建立一个对应着第二个物理磁盘的虚拟磁盘到桌面
 5. 把自己建立的虚拟机的bundle打开，用新建的vmdk替换第一步建立的vmdk。
 6. 打开虚拟机，应该就好了。要是全局重启到windows启动项可能变了，clover不是第一个，bios里调一下。


----------


开始我也试了parallels，和vmware一样它会自动识别你的双系统，并认为你是boot camp技术装的双系统（boot camp按道理说是白苹果装双系统的技术，但是这里我自己分区装的黑苹果双系统也被这样识别了。）官方论坛上说parallels 13把加载第二硬盘的功能砍了，并认为这是一个bug。。。试了一下果然如此。parallels12可以在GUI下加入第二硬盘，软件也有破解，但是每次重启到windows之后第二硬盘的驱动就加载失败，必须把Parallel的tools软件卸载重启后才正常。停止parallels服务也没有用，麻烦得不行。。。最后怒删，还是用vmware fusion。
