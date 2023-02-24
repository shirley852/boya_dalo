
## 准备工作
* 准备一台CentOS6 x64服务器 (推荐腾讯云 阿里云 IDC大宽带)
* CPU/内存：服务器配置最低1核1G
* 带宽：推荐5M以上
* 网络：必须具有固定公网IP

## 安装脚本
如果出现安装失败，请全格重装系统，手动更新yum源后重新执行安装脚本即可。
```shell script
wget --no-check-certificate -O install.sh https://raw.githubusercontent.com/shirley852/boya-dalo/master/install.sh && chmod +x ./install.sh && ./install.sh
```

## 常用命令

> 重启流控 vpn

> 查系统版本 cat /etc/redhat-release

> 查端口开启 netstat -nulp  

> 查服务器时间 date

> 改服务器时间 date -s 09/01/2021

> 禁止ping echo 1 >/proc/sys/net/ipv4/icmp_echo_ignore_all

> 允许ping echo 0 >/proc/sys/net/ipv4/icmp_echo_ignore_all

> 查web端口 netstat -nutlp | grep httpd


## 免责声明
* 此jio本由Shirley于2023.02.24二次修复上传！
* 此jio本在2023.02.24使用CentOS-6.10-x86_64-minimal系统搭建成功！
* 此脚本仅用适用于测试学习，不可用于非法或商业用途，严禁用于任何违法违规用途
* 流控版权为博雅-情韵所有！！
* 所有文件我个人没有加入任何后门，脚本已开源，欢迎检查，不放心的不要用，不要用！不要用！不要用！！ 谢谢！
* 此版本与博雅-情韵官方的DALO版本完全相同，我个人没有加入任何后门、广告，不放心的不要用，不要用！不要用！不要用！！ 谢谢！
## 其他声明
* 流控APP请自行寻找对接。
*
* 任何问题不要问我，不要问我，不要问我。
* 任何问题不要问我，不要问我，不要问我。
* 任何问题不要问我，不要问我，不要问我。


