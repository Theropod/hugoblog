---
title: "Jmeter和tomcat测试相关资料"
date: 2022-10-14T05:35:24+08:00
draft: false
categories:
- WEB相关
tags:
- Tomcat
- Jmeter
---
## 背景
测试异步的模式数据分析接口的性能瓶颈。接口有2个，提交任务和查询任务状态。由于提交数据和获得结果是异步的，用户并发的性能指标测试包含两个阶段。阶段一只要求提交任务可以得到用于查询任务信息的taskid，阶段二需要获取到异步的结果。本此测试场景对于处理时间不敏感，所以阶段二的处理时间不纳入测试，仅要求能够得到结果。
## 工具挑选和教程
根据上述背景，仅需要使用Jmeter（或任意类似软件）向任务提交接口发送一定数量的请求，记录得到所有的taskid的时间。参考：  
- [如何使用Jmeter](https://www.cnblogs.com/stulzq/p/8971531.html)。主要步骤有添加HTTP请求（请求默认值、HTTP信息头、HTTP请求）、响应断言、查看结果树、查看Summary Report等。图形界面调试完成后，用命令行执行，不能用GUI。  
- 如果需要记录每一个请求的时间（阶段二），[如何在Jmeter测试异步接口](https://www.modb.pro/db/243104)，主要区别在于加入一个简单的控制器，从前置结果中提取值来做条件判断。
## 测试时tomcat的一些配置
由于测试了10-1000个任务并发的情况，需要首先提高一下tomcat本身的容量。  
- JVM虚拟机内存，调整最小值最大值。[参考](https://bbs.huaweicloud.com/blogs/319153)
- tomcat支持NIO，从tomcat8开始基本只需在server.xml里面调整maxThreads的大小。[参考](https://cloud.tencent.com/developer/article/1806091)
## 单机解决不了怎么办
使用nginx+tomcat集群（我没有尝试）。[参考](https://juejin.cn/post/7088504913054924837)。
