# IDL中一些容易忘的东西，随用随记


<!--more-->

 - idl矩阵/数组的行列是反的，先列标后行标
 - idl的大小关系运算符不是< >=这种，而是EQ GT GE LT 这种，真是绝了
 - 在ENVI5之后，好多以前的ENVI_GET_DATA这种函数都对象化了。先用e=ENVI(/Headless)无界面打开envi，调用这些新的方便一些的函数。
 - 关于extension的写法，看[这个博客](http://blog.sciencenet.cn/blog-344887-576186.html%20%E5%8D%9A%E5%AE%A2)
 - 有时会报Procedure header must appear first and once的编译错误，最后把这个东西另外保存就能编译过了。。。我算是服了IDL了
