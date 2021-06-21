---
title: "Jupyterlab使用新的tqdm进度条"
date: 2021-01-08T13:59:00+08:00
draft: false
categories:
- 各种姿势
tags:
- JupyterLab
---
需要安装labextension（这一步需要nodejs>=10），开启labextension
tqdm设置from tqdm.auto import trange, tqdm
之后使用就是新的进度条
