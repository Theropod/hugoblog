---
title: "Fork之后设置upstream和origin记录修改、merge主仓库变化"
date: 2021-06-21T20:43:54+08:00
draft: false
categories:
- 各种姿势
tags:
- Github
---
>工程中Fork/Submodule了别人的项目，又有一些修改，如何同步

### 1. Github上Fork一份，用于保存自己的修改
### 2. 在本地Git目录设置origin和upstream  
- 若没有设置，直接设置:  
`git remote add upstream https://github.com/Original-Developer/original-repo.git`  
- 替换：  
`git remote set-url upstream https://github.com/Original-Developer/original-repo.git`  
`git remote set-url origin https://github.com/Myself/my-fork.git`
### 3. 本地修改，提交到origin自己的Fork里面
### 4. 上游有更新需要合并时  
```bash
git fetch upstream #获取更新，这会在本地的新建upstream/master分支 
git checkout master(or working branch) # 一定回到自己的branch
git merge upstream/master # 自动合并两个分支，也许会需要手动
git push origin master # push回去
```
