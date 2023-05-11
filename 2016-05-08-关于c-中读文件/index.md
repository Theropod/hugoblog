# 关于C++中读文件


<!--more-->

创建完ifstream/ofstream/fstream之后，open的方式选择字符或者二进制。

 - **重要：就算选了二进制用read函数，如果存储读来东西的变量不是char型，需要用强制类型转换：(char*)& 你的变量。read函数第一个参数是字符串指针，第二个是你想读的byte数。**
   
 - get和getline不会跳过空白字符，错误少。getline会去掉终止字符（默认/0，可以设置），get不会。

   
 - 但是，用get的时候tellg的值总比read时少1，这就很尴尬了。。。感觉不是很方便，我选择read。
参考：[这个msdn文档](https://msdn.microsoft.com/zh-cn/library/f5tsy854.aspx "msdn")


