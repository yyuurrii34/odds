#!/bin/bash
#以下命令主要是用于新安装的Centos系统或者是新的docker中，一 键优化内核及开 常规端口，可以写在sh文件中统一执行
#使用前请确保能联网
#转载请保住原作者信息： 心飞路漫
#博客地址：https://blog.csdn.net/qq_34924407
#yum源改为阿里云,清理缓存
#\cp -f /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo_bak_`date +"%Y_%m_%d_%H_%M_%S"`;
#wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo;
yum clean all;
yum  -y update;
yum makecache;

#关闭Selinux
\cp -f /etc/selinux/config /etc/selinux/config_bak_`date +"%Y_%m_%d_%H_%M_%S"`;
setenforce 0;
echo '# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=disabled
# SELINUXTYPE= can take one of three two values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected. 
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted 
' > /etc/selinux/config;
#命令行启动
systemctl set-default multi-user.target ;
#转载请保住原作者信息： 心飞路漫
#博客地址：https://blog.csdn.net/qq_34924407
#内核优化
\cp -f /usr/lib/sysctl.d/00-system.conf /usr/lib/sysctl.d/00-system.conf_bak_`date +"%Y_%m_%d_%H_%M_%S"`;

echo "
# Kernel sysctl configuration file
#
# For binary values, 0 is disabled, 1 is enabled.  See sysctl(8) and
# sysctl.conf(5) for more details.

# Disable netfilter on bridges.

net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
#定义了系统中每一个端口最大的监听队列的长度,对于一个经常处理新连接的高负载web服务环境来说，默认的128太小了。
net.core.somaxconn=1280 
#避免放大攻击
net.ipv4.icmp_echo_ignore_broadcasts=1 
#开启恶意icmp错误消息保护
net.ipv4.icmp_ignore_bogus_error_responses=1 
#处理无源路由的包
net.ipv4.conf.all.accept_source_route=0 
net.ipv4.conf.default.accept_source_route=0
#开启SYN洪水攻击保护
net.ipv4.tcp_syncookies=1 
#表示系统同时保持TIME_WAIT套接字的最大数量，
#如果超过这个数字，TIME_WAIT套接字将立刻被清除并打印警告信息。
#默认为180000。设为较小数值此项参数可以控制TIME_WAIT套接字的最大数量，避免服务器被大量的TIME_WAIT套接字拖死。
net.ipv4.tcp_max_tw_buckets=6000 
#它可以用来查找特定的遗失的数据报— 因此有助于快速恢复状态
net.ipv4.tcp_sack=1 
#打开FACK拥塞避免和快速重传功能。(注意，当tcp_sack设置为0的时候，这个值即使设置为1也无效)
net.ipv4.tcp_fack = 1 
#允许TCP发送”两个完全相同”的SACK。
net.ipv4.tcp_dsack = 1 
net.ipv4.tcp_window_scaling=1
# 增加TCP最大缓冲区大小
net.ipv4.tcp_rmem=256 5461 262144 
net.ipv4.tcp_wmem=256 1024 262144
# 开启并记录欺骗，源路由和重定向包
net.ipv4.conf.all.log_martians = 1 
net.ipv4.conf.default.log_martians = 1
# IPv6设置
net.ipv6.conf.default.router_solicitations = 0
net.ipv6.conf.default.accept_ra_rtr_pref = 0
net.ipv6.conf.default.accept_ra_pinfo = 0
net.ipv6.conf.default.accept_ra_defrtr = 0
net.ipv6.conf.default.autoconf = 0
net.ipv6.conf.default.dad_transmits = 0
#net.ipv6.conf.default.max_addresses = 1
# 开启execshild
kernel.exec-shield = 1
kernel.randomize_va_space = 1
# Tcp窗口等
net.core.wmem_default=131072
net.core.rmem_default=131072
net.core.rmem_max = 131072
net.core.wmem_max = 131072
#每个网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目不要设的过大
net.core.netdev_max_backlog=8192 
#表示SYN队列的长度，默认为1024，加大队列长度为8192，可以容纳更多等待连接的网络连接数。
net.ipv4.tcp_max_syn_backlog=8192 
#限制仅仅是为了防止简单的DoS攻击 # #系统所能处理不属于任何进程的TCPsockets最大数量。
#假如超过这个数量，那么不属于任何进程的连接会被立即reset，并同时显示警告信息。
#之所以要设定这个限制﹐纯粹为了抵御那些简单的DoS攻击﹐千万不要依赖这个或是人为的降低这个限制，更应该增加这个值(如果增加了内存之后)。
#每个孤儿套接字最多能够吃掉你64K不可交换的内存。
net.ipv4.tcp_max_orphans=3276800 
#本端试图关闭TCP连接之前重试多少次。缺省值是7，相当于50秒~16分钟(取决于RTO)。
#如果你的机器是一个重载的WEB服务器，你应该考虑减低这个值，因为这样的套接字会消耗很多重要的资源。
net.ipv4.tcp_orphan_retries=3 
#时间戳,0关闭，1开启，在(请参考RFC1323)TCP的包头增加12个字节,
#关于该配置对TIME_WAIT的影响及可能引起的问题:http://huoding.com/2012/01/19/142,Timestamps用在其它一些东西中﹐可以防范那些伪造的sequence号码。
net.ipv4.tcp_timestamps=0 
#内核放弃建立连接之前发送SYNACK包的数量#tcp_synack_retries显示或设定Linux核心在回应SYN要求时会尝试多少次重新发送初始SYN,ACK封包后才决定放弃。
net.ipv4.tcp_synack_retries=1 
#启用timewait快速回收
net.ipv4.tcp_syn_retries=1 
net.ipv4.tcp_tw_recycle=1
#开启重用。允许将TIME-WAITsockets重新用于新的TCP连接
net.ipv4.tcp_tw_reuse=1 
#合适4G的机器 内存大于4G或者小于4G可按情况调整
net.ipv4.tcp_mem = 12288 16384 24576
#（TCP连接最多约使用4GB内存）
net.ipv4.tcp_mem = 32768 43692 65536
net.ipv4.tcp_fin_timeout=5

#当keepalive起用的时候，TCP发送keepalive消息的频度。缺省是2小时
net.ipv4.tcp_keepalive_time=30 
#TCP发送keepalive探测以确定该连接已经断开的次数。(注意:保持连接仅在SO_KEEPALIVE套接字选项被打开是才发送.次数默认不需要修改,当然根据情形也可以适当地缩短此值.设置为5比较合适)
net.ipv4.tcp_keepalive_probes=5 
#探测消息发送的频率，乘以tcp_keepalive_probes就得到对于从开始探测以来没有响应的连接杀除的时间。
net.ipv4.tcp_keepalive_intvl=15 
#允许系统打开的端口范围;缺省情况下很小：32768到61000，改为1024到65000。
net.ipv4.ip_local_port_range=1024 65000 
" >/usr/lib/sysctl.d/00-system.conf;
#生效
sysctl -p;
#转载请保住原作者信息： 心飞路漫
#博客地址：https://blog.csdn.net/qq_34924407

#开放端口，永久,(先删除，可避免系统提示警告)
echo '尝试关闭80端口,有提示是正常的';
firewall-cmd --remove-port=80/tcp --permanent
echo '尝试打开80端口';
firewall-cmd --zone=public --add-port=80/tcp --permanent
echo '尝试关闭3306端口,有提示是正常的';
firewall-cmd --remove-port=3306/tcp --permanent
echo '尝试打开3306端口';
firewall-cmd --zone=public --add-port=3306/tcp --permanent
#检查请使用以下命令
#systemctl restart firewalld.service;
#firewall-cmd  --list-ports 

#先备份原先的hosts
\cp -f /etc/hosts /etc/hosts_bak_`date +"%Y_%m_%d_%H_%M_%S"`;
#输出新的hosts,如果需要加在原hosts后面的请自行调整命令
echo "
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

151.101.44.249 github.global.ssl.fastly.net 
192.30.253.113 github.com 
103.245.222.133 assets-cdn.github.com 
23.235.47.133 assets-cdn.github.com 
203.208.39.104 assets-cdn.github.com 
204.232.175.78 documentcloud.github.com 
204.232.175.94 gist.github.com 
107.21.116.220 help.github.com 
207.97.227.252 nodeload.github.com 
199.27.76.130 raw.github.com 
107.22.3.110 status.github.com 
204.232.175.78 training.github.com 
207.97.227.243 www.github.com 
185.31.16.184 github.global.ssl.fastly.net 
185.31.18.133 avatars0.githubusercontent.com 
185.31.19.133 avatars1.githubusercontent.com
" >/etc/hosts;

#重启网关，才使修改生效
systemctl restart firewalld.service;

yum install lrzsz
#最好是重启系统
echo '最好是重启系统，请输入reboot命令';
#reboot;
