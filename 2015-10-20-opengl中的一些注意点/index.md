# OpenGL中的一些注意点


<!--more-->

- glutDisplayFunction(画图函数)，这个画图函数的最后一句要写上**glutPostRedisplay();**
以标记这个画图函数在glutMainLoop()的每一个循环中都要被执行一次
否则只有在窗口变动的时候才会刷新。。
