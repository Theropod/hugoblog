# 服务器/VSCode ssh转发各种不好使解决

## 转发失败的问题

本来我可以用ssh -N -D来通过服务器转发本地流量，最近失败，-vvv查看也看不出啥，只有channel 2 open failure.
同时，使用VSCode的remote功能也是失败的。

最后发现关闭服务器SELINUX就可以了。。。。

## Windows 默认连接（如VSCode或PowerShell）.ssh\config权限损坏

默认连接貌似需要访问`C:\Users\Theropod3\.ssh\config`权限问题bad owner or permission
教程里都是说要把这个文件安全选项卡权限改成只有用户自己完全控制，其他的全删，但是弄了也没用。PowerShell要是说这个问题就直接把文件删了自动创建，VSCode里还是手动换配置文件路径了

## 用密钥连接服务器，说密钥too open所以不让连接

仍然和之前说的一样，理论上改了权限就可以，但直接换成用户也试过了，不可以。

找到了一个使用默认cacls.exe的方法，复杂操作之后竟然解决了。
<https://blog.yuwu.me/?p=3873>

```powershell
<#
//------------------------------------------------------------------------------
// Function: cacls_to_owner_only
// Change the file access permissions to owner only
//------------------------------------------------------------------------------
#>
function cacls_to_owner_only($file)
{
    if ([System.IO.File]::Exists($file)) {
        $cmds = @(
            "icacls.exe ""$file"" /c /t /inheritance:d",
            "icacls.exe ""$file"" /c /t /grant ${Env:USERNAME}:F",
            "icacls.exe ""$file"" /c /t /remove Administrator BUILTIN\Administrators BUILTIN Everyone System Users ""Authenticated Users"""
        )
        foreach ($cmd in $cmds) {
            Write-Host $cmd
            iex $cmd
            Write-Host ""
        }
    }
    else {
        Write-Error "File not found: ``$file``"
    }
}
```

虽然函数说的是{Env:USERNAME},但是实际权限里看到加入的是字母+数字超长字符的对象

|PEM文件和操作|WSL ssh|WSL sudo ssh|Powershell(管理员无关)|VSCode(管理员无关)|
| -- | -- | -- | -- | -- |
|修改前Windows中权限：Authenticated Users, SYSTEM, Administrators(THEROPOD3\Administrators), users(Theropod3\Users)| too open, 不可以连接 | 可以 | too open | too open|
|使用cacls_to_owner_only后| permission denied | permission denied | permission denied | permission denied|
|安全选项卡再次加上用户完全控制| too open|too open|too open|too open|
|再删掉新加入的对象|too open|可以|可以|可以|

- 总结下来，就是用cacls_to_owner_only，然后把新加上的对象删了，再加上用户。最终结果还是像教程说的，只剩自己的用户名。但是经过中间的操作，就不知道为什么成功，直接操作不成功。

## 原因不明，而且经过其他电脑测试，有的直接没问题，有的上述方案也没用。。。只能说尽量别用Windows干这个

