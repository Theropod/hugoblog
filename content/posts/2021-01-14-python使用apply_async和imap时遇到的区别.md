---
title: "2021 01 14 Python使用apply_async和imap时遇到的区别"
date: 2021-01-14T22:06:13+08:00
draft: false
---
### map/map_async与imap/imap_unordered的区别
1. 传递iterable object的方式  
    - map会把发给他的所有任务iterable转成list，然后分块发给pool中的process。转换成list+分解成块需要把整个list放内存，占空间但是快
    - imap不会转list到内存，默认不分块，每次发送一个iterable到process。这样占用少可以避免内存超额的问题，但是速度降低（可通过手动设置chunksize缓解）[chunksize原理](https://stackoverflow.com/questions/53751050/python-multiprocessing-understanding-logic-behind-chunksize)
2. 它们返回结果的方式
    - map必须执行完返回结果，map_async会立即返回AsyncResult但不是实际完成的值
    - imap和imap_unordered会立即返回结果，因此可以用于tqdm。[tqdm操作方法](https://github.com/tqdm/tqdm/issues/484)
3. imap和imap_unordered  
unordered会比imap稍好，先自动执行小任务出结果，同时总体上内存小一点

[参考链接](https://stackoverflow.com/questions/26520781/multiprocessing-pool-whats-the-difference-between-map-async-and-imap)
### 和apply/apply_async的区别
1. apply仅将一个任务发送给process，在完成前都是block
2. apply_async可以立即获得AsyncResult，任务结束得到值。apply is implemented by simply calling apply_async(...).get()
### 使用中遇到的问题
1. 若希望在multi processing时用tqdm显示进度，不能用同步的map或apply，会阻塞tqdm更新
2. 需要判断 `if __name__ == '__main__':`后再执行imap，否则child process拷贝的运行环境也将尝试开child process，造成套娃。例如在jupyter lab中运行时，若不设置此判断会经常发现任务运行不玩就出错卡死，进程永远不结束。（此判断的原理是，子进程的__name__不再是__main__ [参考](https://cloud.tencent.com/developer/article/1563136)）
3. 开启多进程有fork/spawn/fork_server三种方式 [(官方文档)](https://docs.python.org/3.8/library/multiprocessing.html#contexts-and-start-methods)，windows和interactive的shell采用spawn，会从头开始导入code，很难正确导入。而unix使用fork会直接复制running states，就不会有这个问题。[详见](https://stackoverflow.com/a/50385056)  
例如，children运行需要导入__main__模块，而interactive interpreter（导入code困难）有时会无法运行 [可以参考此节的的Note](https://stackoverflow.com/a/50385056)。 
4. 为此有人会专门把函数写到文件，用多进程时import它，以避免spawn的导入code失败（例如此问题，但当时jupyter会失败，我现在没有遇到此问题 [参考](https://stackoverflow.com/a/54266620)）

### 我在jupyterlab中的一个例子
```python
'''
multiprocessing a for-range function with tqdm showing progess bar, https://github.com/tqdm/tqdm/issues/484
using imap_unordered to start process in a pool and get returned value asynchronously
- need to determine if the module is run by jupyter (__name__ == '__main__') or in a worker(__name__ != '__main__')
  or the created processes will also try to create process and lead to failure(e.g. the process never ends)
# myRange: range of for loop, e.g. range(2001,2020)
# MyFunc: function to by multiprocessed, takes returned value of myRange as the only argument
''' 
def forloop_mp(myRange, myFunc):
    if __name__ == '__main__':
#         pool = mp.Pool(mp.cpu_count())
        pool = mp.Pool(16)
        # to store returned values
        results = []
        # run iteration with tqdm
        for result in tqdm(pool.imap_unordered(myFunc, myRange), total=len(myRange)):
            # if you want to print returned value
#             print(result)
            results.append(result)
        # stop receiving new tasks
        pool.close()
        # block the method until the process whose join() method is called terminates
        pool.join()
        return results
    else:
        raise "Not in Jupyter Notebook"

'''
multiprocessing a for-range function with tqdm showing progess bar, https://github.com/tqdm/tqdm/issues/484
using apply_async to start process in a pool (another way is to use imap_unordered)
# myRange: range of for loop, e.g. range(2001,2020)
# MyFunc: function to by multiprocessed
# params: apply_async can receive multiple args as a list, or you can simple use args=(i, ), which will be the same as imap_unordered
''' 
def forloop_mp_applyasync(myRange, myFunc, params):
    if __name__ == '__main__':
        # progress bar and result list
        pbar = tqdm(total=len(myRange))
        res = [None] * len(myRange)  # result list of correct size

        # callback function to update pbar
        def update(*result):
            pbar.update()
            # if you want to print returned value
    #       print(str(result))

    #   pool = mp.Pool(mp.cpu_count())
        pool = mp.Pool(16)
        for i in myRange:
            pool.apply_async(myFunc, args=params , callback=update)
        # stop receiving new tasks
        pool.close()
        # block the method until the process whose join() method is called terminates
        pool.join()
        # stop updating pbar
        pbar.close()
    else:
        raise "Not in Jupyter Notebook"

''' 
clip raster by mask layer
'''
def clip_raster_by_mask_layer(inputfile, masklayer, outputfile):
    # warp
    gdal.Warp(outputfile, inputfile, format = 'GTiff', cutlineDSName = masklayer)
    print('clipping ' + inputfile)
    return ('clipped ' + inputfile)
'''
the function to be multi processed
'''
def clip_LC_rasters(i):
    input_file = LC_PATH + 'Aligned_LandCover' + str(i) + '_4326.tif'
    output_file = LC_PATH + 'Clipped_LandCover' + str(i) + '_4326.tif'
    mask_layer = BOUND_PATH + 'ChinaBound-FromGov-1000000.shp'
    return clip_raster_by_mask_layer(input_file, mask_layer, output_file)
# call
forloop_mp(range(2001,2020), clip_LC_rasters)
```

### 为什么要用multiprocessing
cpython的GIL（Global Interpreter Lock）默认任何时候单进程只有一个线程能拿到GIL，竞争、切换锁消耗资源，且永远只能同时执行一个线程，效率不高。多核时，其他核心的线程虽然被唤醒-竞争锁，但大概率还是CPU0拿到锁，其他线程回到待调度，造成thrashing，效率更低。
不过，IO密集操作的线程等待时间较长，这时切换到其他线程就可以提高效率。CPU密集则需要multiprocessing  
[参考1](https://zhuanlan.zhihu.com/p/20953544) [参考2](http://cenalulu.github.io/python/gil-in-python/) [参考3](https://python3-cookbook.readthedocs.io/zh_CN/latest/c12/p09_dealing_with_gil_stop_worring_about_it.html)