# 关于Java调用命令行执行NCL

>碰到2次这种需求了：需要给NCL做一个Java Web的套壳，前端参数传给后台，后台用命令行调用NCL出结果。
## 一般的做法
用Runtime类getRuntime().exec()或用p=processbuilder后p.start()  
用jdk的Runtime类可以获得当前java程序的Runtime实例。每个java application只有一个runtime实例，显然这是一个单例模式。
### getRuntime使用需要注意
参考经常被引用的[这篇4个可能遇到的坑](https://www.infoworld.com/article/2071275/when-runtime-exec---won-t.html) 以及[中文版](https://www.jianshu.com/p/af4b3264bc5d)
- 用waitFor()方法等待执行完再调用结果,否则会抛出错误
- 子进程公用父进程的流，要使用bufferreader读取父进程的stream，防止满了之后导致死锁
- 不同平台命令兼容性（我这没这个问题）
- 对stream重定向或者pipeline不能通过shell命令（如2>&1），而是要编程手段解决。比如建立一个工具类新开thread来处理stdout和stderr
## 在NCL中可能遇到的问题和解决
- 脚本的environment和workdir参数，用processbuilder可以方便导入
- getRuntime和processbuilder传参的格式不同，getruntime接受整条命令，processbuilder接受的是分割的命令和参数。getruntime内部是分割后传给processbuilder
- NCL的输出在error，而且shell的重定向是不管用的。processbuilder有redirect方法，可以方便把stderror重定向
- NCL若最后没写quit或exit方法，执行完会一直hang住，用waitFor来控制NCL执行中出问题没退出而超时
- 在waitfor阻塞结束后才能调用bufferreader里面的值，如果想要实时看到执行的结果，需要新开thread，用streamgobbler工具类处理
## processbuilder例子
### 不开thread用工具类
```java
// 导入脚本的环境变量，执行command。重定向stderr，在waitfor阻塞结束之后一起返回结果
public String exeCmd(String command, Map<String, String> environment) {
    try {
        /* use processbuilder to easily redirect errorstream to inputstream */
        ProcessBuilder pb =
                new ProcessBuilder(command.split(" "));
        pb.redirectErrorStream(true);
        Map<String, String> env = pb.environment();
        for (Map.Entry<String, String> entry : environment.entrySet()) {
            env.put(entry.getKey(), entry.getValue());
        }
        Process p = pb.start();
        BufferedReader buf = new BufferedReader(new InputStreamReader(p.getInputStream()));
        StringBuilder logString = new StringBuilder();

        String line;
        while ((line = buf.readLine()) != null) {
            System.out.println(line);
            logString.append(line);
            logString.append("\n");
        }
        // wait for 1 minutes
        boolean exitVal = p.waitFor(1, TimeUnit.MINUTES);
        return (exitVal ? "Finished" : "Timeout") + " log: " + logString;
    } catch (Exception e) {
        //TODO: handle exception
        return "failed " + e;
    }
}
```
### 用streamgobbler工具类处理输出
```java
// class定义略过
    // process builder is expecting string[] and automatically add spaces
    ProcessBuilder builder = new ProcessBuilder(cmd.split(" "));
    builder.directory(new File(this.workingDir));

    Process process = builder.start();

    StreamGobbler outputGobbler = new StreamGobbler(process.getInputStream());
    outputGobbler.start();

    exitVal = process.waitFor(1, TimeUnit.MINUTES);

    nclOutputFile = outputGobbler.getNclOutputFile();
    System.out.println(exitVal ? "NCL Success" : "NCL Failed");

// streamgobbler类
// using nio is a little bit overkill
// use this stream gobbler to deal with output in a new thread
// or, when ncl encounters error and never quits, readline in main tread will be waiting forever
// only killing ncl process will continue the program
public class StreamGobbler extends Thread {
    private InputStream is;
    private String nclOutputFile = "";

    public StreamGobbler(InputStream is) {
        this.is = is;
    }

    public String getNclOutputFile() {
        return nclOutputFile;
    }

    public void run() {
        try {
            InputStreamReader isr = new InputStreamReader(is);
            BufferedReader br = new BufferedReader(isr);
            String line;
            while ((line = br.readLine()) != null) {
                System.out.println(line);
                if (line.contains("Plot Done")) {
                    nclOutputFile = line;
                    nclOutputFile = nclOutputFile.split("./")[1];
                }
            }
        } catch (IOException ioe) {
            ioe.printStackTrace();
        }
    }
}
```
