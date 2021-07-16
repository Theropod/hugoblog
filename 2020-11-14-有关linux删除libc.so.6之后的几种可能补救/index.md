# 有关Linux删除libc.so.6之后的几种可能补救

## 关于libc.so.6
指向了系统GLIBC (GNU C Library) 的某个版本，因此大部分操作如`ls`等都依赖它。如果链接被取消，就无法运行这些命令了。会报  
` error while loading shared libraries: libc.so.6: cannot open shared object file: No such file or directory
`
## 如何修改这个链接
应该用`ln -sf` 否则删完链接，就不能执行命令了。
## 误删或误修改后
### 有root
1. 使用LD_PRELOAD在执行命令之前链接上，动态加载。然后恢复链接
2. 或使用busybox来ln rm等恢复链接。因为redhat的版本是预先编译的，不需要外部的GLIBC，但是并非所有系统都可以
### 无root
1. 不重启，如果有statically-linked的sudo的话可以直接用这个sudo来LD_PRELOAD，但是我试了自己编译一个sudo没有用
2. 重启，用live environment启动，再修改文件链接
3. 重启，进入grub boot menu之后用`init=/bin/busybox/ sh`
4. 重启，进入grub菜单之后用`break=bottom`来打断启动，进入initramfs之后再想办法调用busybox
