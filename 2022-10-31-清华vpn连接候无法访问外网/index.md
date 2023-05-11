# 解决VPN连接后无法访问外网

# 现象
之前使用windows商店安装清华的Pulse Secure VPN可以同时访问校园网和外网，现在发现使用商店版或学校提供的桌面应用版Pulse Secure都没法同时连接了。商店版会直接显示网络连接断开，而学校的应用版导致大部分外网访问慢，google搜索更是不能用。
# 原因
一般认为无法访问外网的原因是路由表被改了，所以很多[教程](https://blog.51cto.com/u_55800/2559574)说只需要取消“在远程网络使用默认网关”后调整路由表就可以，但据隔壁的论坛讨论（有很多相似的帖子）似乎是pulse secure会强制更改锁定路由表，所以调整路由表的方式不能用。 
# 如何解决 
## 使用openconnect
一种解决方法是换openconnect应用，它是开源的，不会改路由表。经实验此应用在linux下没问题，据说mac下也容易用，但windows GUI很久未更新，连接后就闪退。因此只能从交叉编译的rpm包提取exe执行，同时自己需要修改脚本配置。[见此贴](https://bbs.pku.edu.cn/v2/post-read.php?bid=35&threadid=18023201)
## 手动改DNS
另一种就是在每次pulse secure桌面应用版连接后手动改VPN适配器的DNS，从学校的改为谷歌的。此方法是基于以下的多个改windows设置、路由表、跃点值等操作的对比中唯一可用的。[工作表链接](https://docs.google.com/spreadsheets/d/1k_i4v2Al0FNA2MpfqPRDA74m8N6azy-bdqzfMIhfaqA/edit?usp=sharing)
<iframe src="https://docs.google.com/spreadsheets/d/e/2PACX-1vQAX_ww7Cukx5PNsE3qBlltJPZgnXyRy0865TIwt_mZTARKRJwsjXEgc4LffaRol0zogbQU5SuniDBi/pubhtml?gid=0&amp;single=true&amp;widget=true&amp;headers=false" style="width: 100%; height: 500px; top: 0;"></iframe>

# 结论
由于学校的vpn是zerotier远程桌面不稳的时候应急的，所以每次改DNS就能够满足需求。最终还是应当配置私有的Moon服务器保证多个zerotier节点之间的网络连接稳定。


