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
2. apply_async可以立即获得AsyncResult，任务结束得到值,可以用于tqdm。[(tqdm操作方法)](https://github.com/tqdm/tqdm/issues/484)  
apply is implemented by simply calling apply_async(...).get()
### 使用中遇到的问题
1. 若希望在multi processing时用tqdm显示进度，不能用同步的map或apply，会阻塞tqdm更新
2. 尽量显式传参给子进程
    - 虽然unix的fork方式可以让子进程使用父进程的全局变量，但仍建议传参
    - 原因：Windows兼容、别处也可直接调用、防止子进程alive时资源GC
3. 有关Windows/Interactive环境下执行
    - 开启多进程有fork/spawn/fork_server三种方式 [(官方文档)](https://docs.python.org/3.8/library/multiprocessing.html#contexts-and-start-methods)，windows和interactive的shell采用spawn，会很难从头开始导入code。而unix使用fork会直接复制running states，就不会有这个问题。[详见](https://stackoverflow.com/a/50385056) 
    - 因此，Windows下需要判断 `if __name__ == '__main__':`后再执行imap等开启多进程，称为protect the main function [(否则会导致main中内容又执行一遍)](https://stackoverflow.com/a/45110493)，官方文档的programming guidline也提示[safe importing of main module](https://docs.python.org/3.8/library/multiprocessing.html#the-spawn-and-forkserver-start-methods)  
    - 但是，有时children需要__main__模块的内容才能正确运行，而Windows下子进程的__name__不再是__main__ [参考](https://cloud.tencent.com/developer/article/1563136)，因此需要用到的资源要在`if __name__ == '__main__':`之前确定好,在这语句之后的值不会传递到子进程里。interactive interpreter（导入code困难）有时会无法运行 [可以参考此节的的Note](https://docs.python.org/3.8/library/multiprocessing.html#using-a-pool-of-workers)
    - 为此有人会专门把函数写到文件，用多进程时import它，以避免spawn的导入code失败（此处的jupyter会失败，我现在没有遇到此问题 [参考](https://stackoverflow.com/a/54266620)）

### 在jupyterlab中的一个例子
```python
# import multiprocessing as mp
# this module is a fork of official multiprocessing and I believe is faster
import multiprocess as mp

# pool
# pool = mp.Pool(mp.cpu_count())
pool = mp.Pool(16)

'''
multiprocessing a for-range function with tqdm showing progess bar, https://github.com/tqdm/tqdm/issues/484
using imap_unordered to start process in a pool and get returned value asynchronously
- imap_unordered only takes one argument(the iterator), if you need multiple arguments, you have to wrap all arguments into one new iterator
# myRange: range of for loop, e.g. range(2001,2020)
# MyFunc: function to by multiprocessed, takes returned value of myRange as the only argument
''' 
def forloop_mp(myRange, myFunc):
    if __name__ == '__main__':
        # start a pool
        # with mp.Pool(processes=mp.cpu_count()) as pool:
        with mp.Pool(processes=16) as pool:
         
            # to store returned values
            results = []
            # run iteration with tqdm
            # expecting a message to print and the returned result of each iteration
            for (msg, result) in tqdm(pool.imap_unordered(myFunc, myRange), total=len(myRange)):
                # if you want to print returned message
                print(msg)
                results.append(result)
            # stop receiving new tasks
            pool.close()
            # block the method until the process whose join() method is called terminates
            pool.join()
            # exiting the 'with'-block has stopped the pool, dont terminate it manually
            # pool.terminate()
            
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
        # start a pool
        # with mp.Pool(processes=mp.cpu_count()) as pool:
        with mp.Pool(processes=16) as pool:
            
            # progress bar and result list
            pbar = tqdm(total=len(myRange))
            results = [None] * len(myRange)  # result list of correct size

            # callback function to update pbar
            # expecting a message to print and the returned result of each iteration    
            def update(msg, result):
                pbar.update()
                # if you want to print returned value
                print(msg)
                results.append(result)

            for i in myRange:
                pool.apply_async(myFunc, args=(i, params) , callback=update)

            # stop receiving new tasks
            pool.close()
            # block the method until the process whose join() method is called terminates
            pool.join()
            # stop updating pbar
            pbar.close()
            # exiting the 'with'-block has stopped the pool, dont terminate it manually
            # pool.terminate()
            
        return results
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