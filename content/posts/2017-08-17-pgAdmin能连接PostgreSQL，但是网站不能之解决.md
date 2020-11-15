---
title: pgAdmin能连接PostgreSQL，但是网站不能之解决
date: 2017-08-17 15:35:34
tags: 
- postgresql
- spring
categories:
- 网站相关
---

<!--more-->

 

 

 -  网站是在spring mvc框架下写的，从服务器上访问服务器localhost:5432的数据库没有问题，但是同样的程序想在我的电脑上连自己电脑的数据库的时候就不行，报错。
  这个错误到处都能查得到：
 

> Request processing failed; nested exception is org.springframework.jdbc.CannotGetJdbcConnectionException: Could not get JDBC Connection; nested exception is java.sql.SQLException: Cannot create PoolableConnectionFactory (Connection to localhost:5432 refused. Check that the hostname and port are correct and that the postmaster is accepting TCP/IP connections.)



- 但是网上都是说让你查看pg_hba.conf和postgresql.conf，看看访问权限和监听地址设置对了没有。虽然连Localhost是不需要设置的，但我还是把可能的组合试遍了。奇怪的是pgadmin和psql就完全没有问题。。。后来又发现Navicat可以，IntelliJ IDEA自带的连接功能不行。
PowerShell看了一下端口，5432确实在监听，PID也是postgres，但是这里的地址写的是[::1]:5432
于是把dataSource中的jdbc.url从localhost改成[::1]，就神奇地好了。本来还想把系统的默认localhost改成127.0.0.1,看来也不用了。
 
真的奇怪。