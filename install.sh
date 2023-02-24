#!/bin/bash
#博雅-DALO版权所有
#情韵QQ 2223139086
#此jio本由Shirley于2023.02.24二次修复上传！
#此jio本在2023.02.24使用CentOS-6.10-x86_64-minimal系统搭建成功！
#任何问题不要问我！
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH


Select_resource_host()
{
	
	echo "请选择安装源地址"
	echo "1、博雅腾讯云对象存储（大陆）"
	echo "2、GitHub"
	read -p "请选择[1-2]: " Host_Option
	if [ "$Host_Option" = "1" ]; then
		#相同
		echo "您选择的安装源地址为：1、博雅腾讯云对象存储（大陆）"
		Download_Host='http://radius-1253794729.cosgz.myqcloud.com/data';
	else
		if [ "$Host_Option" = "2" ]; then
			#相同
			echo "您选择的安装源地址为：2、GitHub"
			Download_Host="";
		else
			#不相同
			echo "检测到您未选择安装源或选择错误，系统默认为您选择安装源地址为：1、博雅腾讯云对象存储（大陆）"
			Download_Host='http://radius-1253794729.cosgz.myqcloud.com/data';
		fi
	fi
	
	return;
	
}


Inspection_before_installation()
{
	if [ ! -f /bin/mv ]; then
		echo "程序异常退出！"
		exit
	fi

	if [ ! -f /bin/rm ]; then
		echo "程序异常退出！"
		exit
	fi

	if [ ! -f /bin/cp ]; then
		echo "程序异常退出！"
		exit
	fi
	
	if [ -f /etc/os-release ];then
		OS_VERSION=`cat /etc/os-release |awk -F'[="]+' '/^VERSION_ID=/ {print $2}'`
		if [ $OS_VERSION != "6" ];then
			echo -e "\n当前系统版本为：\033[1;32mCentOS $OS_VERSION\033[0m\n"
			echo "暂不支持该系统安装"
			echo "请更换 CentOS 6 系统进行安装"
			exit 0;
		fi
	elif [ -f /etc/redhat-release ];then
		OS_VERSION=`cat /etc/redhat-release |grep -Eos '\b[0-9]+\S*\b' |cut -d'.' -f1`
		if [ $OS_VERSION != "6" ];then
			echo -e "\n当前系统版本为：\033[1;32mCentOS $OS_VERSION\033[0m\n"
			echo "暂不支持该系统安装"
			echo "请更换 CentOS 6 系统进行安装"
			exit 0;
		fi
	else
		echo -e "当前系统版本为：\033[1;32m未知\033[0m\n"
		echo "暂不支持该系统安装"
		echo "请更换 CentOS 6 系统进行安装"
		exit 0;
	fi
	
	if [[ "$EUID" -ne 0 ]]; then  
		echo "对不起，您需要以root身份运行"  
		exit
	fi
	
	
	if [[ ! -e /dev/net/tun ]]; then  
		echo "TUN不可用"  
		exit
	fi
	
	return;
}


Install_System_environment()
{
	clear
	echo "正在安装系统支持库..."
	setenforce 0
	#配置repos
	#2023.02.16修复repo
	rm -rf /etc/yum.repos.d/*
	
	echo '# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the 
# remarked out baseurl= line instead.
#
#

[base]
name=CentOS-$releasever - Base
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra
baseurl=https://mirrors.aliyun.com/centos-vault/6.10/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#released updates 
[updates]
name=CentOS-$releasever - Updates
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates&infra=$infra
baseurl=https://mirrors.aliyun.com/centos-vault/6.10/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras&infra=$infra
baseurl=https://mirrors.aliyun.com/centos-vault/6.10/extras/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus&infra=$infra
baseurl=https://mirrors.aliyun.com/centos-vault/6.10/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

#contrib - packages by Centos Users
[contrib]
name=CentOS-$releasever - Contrib
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=contrib&infra=$infra
baseurl=https://mirrors.aliyun.com/centos-vault/6.10/contrib/$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6' > /etc/yum.repos.d/CentOS-Base.repo
	
	echo '# CentOS-Debug.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#

# All debug packages from all the various CentOS-5 releases
# are merged into a single repo, split by BaseArch
#
# Note: packages in the debuginfo repo are currently not signed
#

[base-debuginfo]
name=CentOS-6 - Debuginfo
baseurl=http://debuginfo.centos.org/6/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Debug-6
enabled=0' > /etc/yum.repos.d/CentOS-Debuginfo.repo
	
	echo '[fasttrack]
name=CentOS-6 - fasttrack
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=fasttrack&infra=$infra
baseurl=https://mirrors.aliyun.com/centos-vault/6.10/fasttrack/$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6' > /etc/yum.repos.d/CentOS-fasttrack.repo
	
	echo '# CentOS-Media.repo
#
#  This repo can be used with mounted DVD media, verify the mount point for
#  CentOS-6.  You can use this repo and yum to install items directly off the
#  DVD ISO that we release.
#
# To use this repo, put in your DVD and use it with the other repos too:
#  yum --enablerepo=c6-media [command]
#  
# or for ONLY the media repo, do this:
#
#  yum --disablerepo=\* --enablerepo=c6-media [command]
 
[c6-media]
name=CentOS-$releasever - Media
baseurl=file:///media/CentOS/
        file:///media/cdrom/
        file:///media/cdrecorder/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6' > /etc/yum.repos.d/CentOS-Media.repo
	
	yum clean all >/dev/null 2>&1
	yum makecache >/dev/null 2>&1
	
	yum -y install epel-release >/dev/null 2>&1
	
	yum install -y unzip zip vim vim-runtime gcc-c++ libgcrypt libgpg-error libgcrypt-devel nload wget curl exim make openssl openssl-devel net-tools psmisc nss libcurl telnet freetype-devel glib2-devel cairo-devel libjpeg* libodbc libodbc++ t1lib libmcrypt libc-client libXpm libexslt libxslt* >/dev/null 2>&1
	return;
}

	
Install_Firewall()
{
	echo "安装防火墙..."
	setenforce 0
	yum install iptables -y >/dev/null 2>&1
	iptables -P INPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -t nat -P PREROUTING ACCEPT
	iptables -t nat -P POSTROUTING ACCEPT
	iptables -t nat -P OUTPUT ACCEPT
	iptables -F
	iptables -t nat -F
	iptables -X
	iptables -t nat -X
	service iptables save >/dev/null 2>&1
	service iptables restart >/dev/null 2>&1
	iptables -t nat -A PREROUTING -d 10.0.0.0/32 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 3389
	iptables -t nat -A POSTROUTING -s 10.7.0.0/16 ! -d 10.7.0.0/16 -j MASQUERADE
	iptables -t nat -A POSTROUTING -s 10.8.0.0/16 ! -d 10.8.0.0/16 -j MASQUERADE
	iptables -t nat -A POSTROUTING -s 10.9.0.0/16 ! -d 10.9.0.0/16 -j MASQUERADE
	iptables -t nat -A POSTROUTING -s 10.10.0.0/16 ! -d 10.10.0.0/16 -j MASQUERADE
	iptables -t nat -A POSTROUTING -s 10.11.0.0/16 ! -d 10.11.0.0/16 -j MASQUERADE
	iptables -t nat -A POSTROUTING -s 10.12.0.0/16 ! -d 10.12.0.0/16 -j MASQUERADE
	iptables -t nat -A OUTPUT -d 10.7.0.1/32 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 3389
	iptables -t nat -A OUTPUT -d 10.8.0.1/32 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 3389
	iptables -t nat -A OUTPUT -d 10.9.0.1/32 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 3389
	iptables -t nat -A OUTPUT -d 10.10.0.1/32 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 3389
	iptables -t nat -A OUTPUT -d 10.11.0.1/32 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 3389
	iptables -t nat -A OUTPUT -d 10.12.0.1/32 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 3389
	iptables -I INPUT -p tcp --dport ${lkdk} -j ACCEPT
	iptables -I INPUT -p udp --dport 1812 -j ACCEPT
	iptables -I INPUT -p udp --dport 1813 -j ACCEPT
	iptables -I INPUT -p udp --dport 1814 -j ACCEPT
	iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
	iptables -I INPUT -p udp --dport 138 -j ACCEPT
	iptables -I INPUT -p udp --dport 137 -j ACCEPT
	iptables -I INPUT -p tcp --dport 138 -j ACCEPT
	iptables -I INPUT -p tcp --dport 137 -j ACCEPT
	iptables -I INPUT -p tcp --dport 53 -j ACCEPT
	iptables -I INPUT -p tcp --dport 524 -j ACCEPT
	iptables -I INPUT -p tcp --dport 1026 -j ACCEPT
	iptables -I INPUT -p tcp --dport 8081 -j ACCEPT
	iptables -I INPUT -p tcp --dport 180 -j ACCEPT
	iptables -I INPUT -p tcp --dport 53 -j ACCEPT
	iptables -I INPUT -p tcp --dport 351 -j ACCEPT
	iptables -I INPUT -p tcp --dport 366 -j ACCEPT
	iptables -I INPUT -p tcp --dport 443 -j ACCEPT
	iptables -I INPUT -p tcp --dport 440 -j ACCEPT
	iptables -I INPUT -p tcp --dport 3389 -j ACCEPT
	iptables -I INPUT -p tcp --dport 3311 -j ACCEPT
	iptables -I INPUT -p tcp --dport 3322 -j ACCEPT
	iptables -I INPUT -p tcp --dport 3333 -j ACCEPT
	iptables -I INPUT -p tcp --dport 3344 -j ACCEPT
	iptables -I INPUT -p tcp --dport 3355 -j ACCEPT
	iptables -I INPUT -p tcp --dport 80 -j ACCEPT
	iptables -I INPUT -p tcp --dport 1194 -j ACCEPT
	iptables -t nat -A OUTPUT -d 192.168.255.1/32 -p tcp -j REDIRECT --to-ports 3389
	service iptables save >/dev/null 2>&1
	service iptables restart >/dev/null 2>&1
	#timedatectl set-timezone Asia/Shanghai
	#\cp -rf /usr/share/zoneinfos/Asia/Shanghai /etc/localtime >/dev/null 2>&1
	rm -rf /etc/sysctl.conf
	echo "net.ipv4.ip_forward = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.tcp_congestion_control= hybla
net.core.rmem_default = 256960  
net.core.rmem_max = 513920  
net.core.wmem_default = 256960  
net.core.wmem_max = 513920  
net.core.netdev_max_backlog = 2000  
net.core.somaxconn = 2048  
net.core.optmem_max = 81920  
net.ipv4.tcp_mem = 131072  262144  524288  
net.ipv4.tcp_rmem = 8760  256960  4088000  
net.ipv4.tcp_wmem = 8760  256960  4088000  
net.ipv4.tcp_keepalive_time = 1200  
net.ipv4.tcp_keepalive_intvl = 30  
net.ipv4.tcp_keepalive_probes = 3  
net.ipv4.tcp_sack = 1  
net.ipv4.tcp_fack = 1  
net.ipv4.tcp_timestamps = 1  
net.ipv4.tcp_window_scaling = 1  
net.ipv4.tcp_syncookies = 1  
net.ipv4.tcp_tw_reuse = 1  
net.ipv4.tcp_tw_recycle = 1  
net.ipv4.tcp_fin_timeout = 15  
net.ipv4.ip_local_port_range = 10000  65000  
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_retries2 = 5">/etc/sysctl.conf
	chmod -R 0777 /etc/sysctl.conf
	sysctl -p >/dev/null 2>&1
	return;
}


Install_MySQL()
{
	echo "安装MySQL..."
	yum -y install mysql mysql-server >/dev/null 2>&1
	service mysqld start >/dev/null 2>&1
	mysqladmin -uroot password "${sqladmin}"
	mysql -uroot -p${sqladmin} -e "create database radius;"
	return;
}

Install_Radius()
{
	echo "安装Radius..."
	yum -y install freeradius freeradius-mysql freeradius-utils >/dev/null 2>&1
	cd /etc/raddb
	wget ${Download_Host}/raddb.zip >/dev/null 2>&1
	unzip -o raddb.zip >/dev/null 2>&1
	rm -rf raddb.zip
	
	sed -i "s/'administrator','radius'/'$administrator','$boya123'/g" /etc/raddb/sql/freeradius.sql
	mysql -u root -p${sqladmin} radius < /etc/raddb/sql/mysql/admin.sql  
	mysql -u root -p${sqladmin} radius < /etc/raddb/sql/mysql/schema.sql  	
	mysql -u root -p${sqladmin} radius < /etc/raddb/sql/mysql/nas.sql  
	mysql -u root -p${sqladmin} radius < /etc/raddb/sql/mysql/ippool.sql
	mysql -u root -p${sqladmin} radius < /etc/raddb/sql/freeradius.sql
	
	return;
}


Install_OpenVPN()
{
	echo "安装OpenVPN..."
	yum install openvpn -y >/dev/null 2>&1
	rm -rf /etc/openvpn/*
	cd /etc/openvpn
	wget ${Download_Host}/openvpn.zip >/dev/null 2>&1
	unzip -o openvpn.zip >/dev/null 2>&1
	rm -rf openvpn.zip
	sed -i "s/port 3311/port 440/g" /etc/openvpn/server1.conf
	sed -i "s/NAS-IP-Address=127.0.0.1/NAS-IP-Address=${IP}/g" /etc/openvpn/radiusplugin*.cnf
	
	cd /root
	
	
	wget http://www.nongnu.org/radiusplugin/radiusplugin_v2.1a_beta1.tar.gz >/dev/null 2>&1
	tar zxvf radiusplugin_v2.1a_beta1.tar.gz >/dev/null 2>&1
	cd /root/radiusplugin_v2.1a_beta1
	make >/dev/null 2>&1
	rm -rf /etc/openvpn/radiusplugin.so
	cp /root/radiusplugin_v2.1a_beta1/radiusplugin.so /etc/openvpn >/dev/null 2>&1
	
	chmod -R 0777 /etc/openvpn/
	#service openvpn restart
	return;
}

Install_Squid()
{
	echo "安装Squid..."
	yum -y install squid >/dev/null 2>&1
	rm -rf /etc/squid/squid.conf
	rm -rf /etc/squid/squid_passwd
	echo "
visible_hostname 2223139086@qq.com
shutdown_lifetime 3 seconds
acl localnet src 10.0.0.0/8
acl localnet src 172.16.0.0/12
acl localnet src 192.168.0.0/16
acl localnet src fc00::/7
acl localnet src fe80::/10
acl Safe_ports port 80
acl Safe_ports port 3389
acl Safe_ports port 443
acl Safe_ports port 440
acl Safe_ports port 8080
acl Safe_ports port 53
acl CONNECT method CONNECT
http_access deny !Safe_ports
http_access allow CONNECT Safe_ports
acl allowedip dst 172.17.0.2
acl alloweddomain dstdomain a.10086.cn
acl alloweddomain dstdomain a.mll.migu.cn
acl alloweddomain dstdomain box.10155.com
acl alloweddomain dstdomain cdn.4g.play.cn
acl alloweddomain dstdomain dl.music.189.cn
acl alloweddomain dstdomain iread.wo.com.cn
acl alloweddomain dstdomain ltetp.tv189.cn
acl alloweddomain dstdomain m.10010.com
acl alloweddomain dstdomain m.client.10010.com
acl alloweddomain dstdomain migumovie.lovev.com
acl alloweddomain dstdomain m.iread.wo.com.cn
acl alloweddomain dstdomain m.miguvideo.com
acl alloweddomain dstdomain mmsc.monternet.com
acl alloweddomain dstdomain mmsc.myuni.com.cn
acl alloweddomain dstdomain mob.10010.com
acl alloweddomain dstdomain music163.gzproxy.10155.host
acl alloweddomain dstdomain music.migu.cn
acl alloweddomain dstdomain mv.wo.com.cn
acl alloweddomain dstdomain rd.go.10086.cn
acl alloweddomain dstdomain shoujibao.net
acl alloweddomain dstdomain touch.10086.cn
acl alloweddomain dstdomain uac.10010.com
acl alloweddomain dstdomain wap.10010.com
acl alloweddomain dstdomain wap.10086.cn
acl alloweddomain dstdomain wap.10155.com
acl alloweddomain dstdomain wap.17wo.com
acl alloweddomain dstdomain wap.bj.10086.cn
acl alloweddomain dstdomain wap.cmread.com
acl alloweddomain dstdomain wap.cmvideo.cn
acl alloweddomain dstdomain wap.cq.10086.cn
acl alloweddomain dstdomain wap.fj.10086.cn
acl alloweddomain dstdomain wap.gd.10086.cn
acl alloweddomain dstdomain wap.gs.10086.cn
acl alloweddomain dstdomain wap.gx.10086.cn
acl alloweddomain dstdomain wap.gz.10086.cn
acl alloweddomain dstdomain wap.hb.10086.cn
acl alloweddomain dstdomain wap.hi.10086.cn
acl alloweddomain dstdomain wap.hl.10086.cn
acl alloweddomain dstdomain wap.hn.10086.cn
acl alloweddomain dstdomain wap.jf.10086.cn
acl alloweddomain dstdomain wap.js.10086.cn
acl alloweddomain dstdomain wap.jx.10086.cn
acl alloweddomain dstdomain wap.sc.10086.cn
acl alloweddomain dstdomain wap.sd.10086.cn
acl alloweddomain dstdomain wap.sh.10086.cn
acl alloweddomain dstdomain wap.sz.10086.cn
acl alloweddomain dstdomain wap.yn.10086.cn
acl alloweddomain dstdomain wap.zj.10086.cn
acl alloweddomain dstdomain wap.jn.10086.cn
acl alloweddomain dstdomain wap.tj.10086.cn
acl alloweddomain dstdomain wap.nx.10086.cn
acl alloweddomain dstdomain wap.ah.10086.cn
acl alloweddomain dstdomain wap.sx.10086.cn
acl alloweddomain dstdomain wap.sn.10086.cn
acl alloweddomain dstdomain wap.xj.10086.cn
acl alloweddomain dstdomain wap.he.10086.cn
acl alloweddomain dstdomain wap.ha.10086.cn
acl alloweddomain dstdomain wap.xz.10086.cn
acl alloweddomain dstdomain wapzt.189.cn
acl alloweddomain dstdomain xiami.gzproxy.10155.com
acl alloweddomain dstdomain zjw.mmarket.com
acl alloweddomain dstdomain www.baidu.com
acl alloweddomain dstdomain wap.ln.10086.cn
acl alloweddomain dstdomain m.t.17186.cn
acl alloweddomain dstdomain gslb.miguvod.lovev.com
acl alloweddomain dstdomain data.10086.cn
acl alloweddomain dstdomain freetyst.mll.migu.cn
acl alloweddomain dstdomain mll.migu.cn
acl alloweddomain dstdomain www.10155.com
acl alloweddomain dstdomain wap.17wo.cn
acl alloweddomain dstdomain 3gwap.10010.com
acl alloweddomain dstdomain love9999.top
acl alloweddomain dstdomain www.10010.com
acl alloweddomain dstdomain kugou.gzproxy.10155.com
acl alloweddomain dstdomain ltetptv.189.com
acl alloweddomain dstdomain ltetp.tv189.com
acl alloweddomain dstdomain iting.music.189.cn
http_access allow allowedip
http_access allow alloweddomain
http_port 80
coredump_dir /var/spool/squid
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320
">/etc/squid/squid.conf
	echo "admin@www.52hula.cn:yYUhGhiABVJGI">/etc/squid/squid_passwd
	cd /sbin
	wget ${Download_Host}/udp.zip >/dev/null 2>&1
	unzip -o udp.zip >/dev/null 2>&1
	gcc -o mproxy udp.c >/dev/null 2>&1
	rm -rf udp.zip udp.c
	
	return;
}



Install_Haproxy()
{
	echo "安装Haproxy..."
	yum install -y haproxy >/dev/null 2>&1
	rm -rf /etc/haproxy/haproxy.cfg
	echo "
global
log 127.0.0.1 local2
chroot /var/lib/haproxy
pidfile /var/run/haproxy.pid
maxconn 4000
user haproxy
group haproxy
daemon
stats socket /var/lib/haproxy/stats
defaults
mode tcp
log global
option httplog
option dontlognull
option http-server-close
#option forwardfor except 127.0.0.0/8
option redispatch
option splice-auto
retries 3
timeout http-request 10s
timeout queue 1m
timeout connect 10s
timeout client 1m
timeout server 1m
timeout http-keep-alive 10s
timeout check 10s
maxconn 60000
listen vpn
bind 0.0.0.0:3389
bind 0.0.0.0:443
bind 0.0.0.0:1194
mode tcp
option tcplog
option splice-auto
balance roundrobin
maxconn 60000
server s1 127.0.0.1:3311 maxconn 10000 maxqueue 60000
server s2 127.0.0.1:3322 maxconn 10000 maxqueue 60000
server s3 127.0.0.1:3333 maxconn 10000 maxqueue 60000
server s4 127.0.0.1:3344 maxconn 10000 maxqueue 60000">/etc/haproxy/haproxy.cfg
	return;
}

Install_dnsmasq()
{
	echo "安装dnsmasq..."
	yum install dnsmasq -y >/dev/null 2>&1
	rm -rf /etc/dnsmasq.conf
	echo "port=5353
server=114.114.114.114
address=/rd.go.10086.cn/10.8.0.1
listen-address=127.0.0.1
conf-dir=/etc/dnsmasq.d">/etc/dnsmasq.conf
	return;
}




Install_Apache()
{
	echo "安装Apache+PHP(国内服务器可能会卡在安装PHP，请耐心等待...)"
	yum install -y httpd >/dev/null 2>&1
	rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm >/dev/null 2>&1
	yum install --enablerepo=remi --enablerepo=remi-php56 -y httpd php php-gd php-mysql php-pear php-pear-DB >/dev/null 2>&1
	pear install MDB2 >/dev/null 2>&1
	sed -i "s/#ServerName www.example.com:80/ServerName localhost:$lkdk/g" /etc/httpd/conf/httpd.conf
	sed -i "s/ServerTokens OS/ServerTokens Prod/g" /etc/httpd/conf/httpd.conf
	sed -i "s/ServerSignature On/ServerSignature Off/g" /etc/httpd/conf/httpd.conf
	sed -i "s/Options Indexes MultiViews FollowSymLinks/Options MultiViews FollowSymLinks/g" /etc/httpd/conf/httpd.conf
	sed -i "s/#ServerName www.example.com:80/ServerName localhost:$lkdk/g" /etc/httpd/conf/httpd.conf
	sed -i "s/80/$lkdk/g" /etc/httpd/conf/httpd.conf
	sed -i "s/magic_quotes_gpc = Off/magic_quotes_gpc = On/g" /etc/php.ini
	setsebool httpd_can_network_connect 1
	cat >> /etc/httpd/conf/httpd.conf <<EOF
Listen ${cxlldk}
<VirtualHost *:${cxlldk}>
        ServerAdmin webmaster@hehe.com
    DocumentRoot "/var/www/user"
    ServerName freetraffic.com
    ErrorLog "logs/hehe.com-error.log"
    CustomLog "logs/hehe.com-access.log" common
</VirtualHost>
Listen ${appjiemian}
<VirtualHost *:${appjiemian}>
        ServerAdmin webmaster@hehe.com
    DocumentRoot "/var/www/myapp"
    ServerName freetraffic.com
    ErrorLog "logs/hehe.com-error.log"
    CustomLog "logs/hehe.com-access.log" common
</VirtualHost>
EOF
	
	cd /var/www
	rm -rf htmly.zip
	wget ${Download_Host}/htmly.zip >/dev/null 2>&1
	unzip -o htmly.zip >/dev/null 2>&1
	mv /var/www/html/admin /var/www/html/${wenjian} >/dev/null 2>&1
	chmod -R 0777 /var/www
	
	echo "vpn">> /etc/rc.d/rc.local
	mysql -uradius -phehe123 -e "UPDATE radius.radacct SET acctstoptime = acctstarttime + acctsessiontime WHERE ((UNIX_TIMESTAMP(acctstarttime) + acctsessiontime + 240 - UNIX_TIMESTAMP())<0) AND acctstoptime IS NULL;"
	
	return;
}

Install_Done() 
{
	clear
	echo -e "\033[1;32m"
	echo "=========================================================================="
	echo "                          博雅-DALO 稳定版 安装完成                          "
	echo "																			"
	echo "			以下信息将自动保存到/root/info.txt文件中		"
	echo "                                                                          "
	echo "                            博雅-DALO服务器信息                           "
	echo "                                                                          "
	echo "                   查询流量地址：( "$IP":"$cxlldk" )                           "
	echo "                   APP 下载地址：( "$IP":"$appjiemian" )脑残勿用此链接    		    "
	echo "                   后台管理地址：( "$IP":"$lkdk"/"$wenjian" )             "
	echo "                   线路模板地址：( "$IP":"$lkdk"/test.ovpn )				"
	echo "                   后台管理账号: "$administrator" 密码: "$boya123"        "
	echo "                   数据库  账号: root  密码: "$sqladmin"                  "
	echo "                           重启VPN命令：vpn                               "
	echo "温馨提示下 这个脚本443 440 3389 1026 53 1194 都开了的！别瞎鸡巴弄了！我懒得售后啊！"
	echo "=========================================================================="
	echo -e "\033[0m"
	echo "auth-user-pass
client
comp-lzo
proto tcp
dev tun
############################
remote "$IP" 1194
############################
keepalive 10 60
setenv tls-remote
key-direction 1
nobind
ns-cert-type server
persist-key
setenv CLIENT_CERT 0
verb 1
<ca>
-----BEGIN CERTIFICATE-----
MIIDyDCCAzGgAwIBAgIJAMMPpgLTPPACMA0GCSqGSIb3DQEBCwUAMIGfMQswCQYD
VQQGEwJDTjELMAkGA1UECBMCWkoxCzAJBgNVBAcTAllEMRUwEwYDVQQKEwxGb3J0
LUZ1bnN0b24xHTAbBgNVBAsTFE15T3JnYW5pemF0aW9uYWxVbml0MQswCQYDVQQD
EwJjYTEQMA4GA1UEKRMHRWFzeVJTQTEhMB8GCSqGSIb3DQEJARYSbWVAbXlob3N0
Lm15ZG9tYWluMB4XDTE2MDQwODA4Mzk1N1oXDTI2MDQwNjA4Mzk1N1owgZ8xCzAJ
BgNVBAYTAkNOMQswCQYDVQQIEwJaSjELMAkGA1UEBxMCWUQxFTATBgNVBAoTDEZv
cnQtRnVuc3RvbjEdMBsGA1UECxMUTXlPcmdhbml6YXRpb25hbFVuaXQxCzAJBgNV
BAMTAmNhMRAwDgYDVQQpEwdFYXN5UlNBMSEwHwYJKoZIhvcNAQkBFhJtZUBteWhv
c3QubXlkb21haW4wgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBAK5K7bd0Mb/a
Kp6FCcY3HTxIE9fwaUFofLIyRdiMengDv+Iy44+SwIzwXW8Empo3/I7b87GwNGXW
1Mi7sYx6O1yj4IDoGK6DXwm4roH5v4LT9PCbeCC+r1mhMRdcsCZXYLhnTz1ZP+ZS
SgelwfZNQXhNO6kwfQxe6aYzXroAywX9AgMBAAGjggEIMIIBBDAdBgNVHQ4EFgQU
e4hUGrEtghIYAMwDdogl1yN+N8swgdQGA1UdIwSBzDCByYAUe4hUGrEtghIYAMwD
dogl1yN+N8uhgaWkgaIwgZ8xCzAJBgNVBAYTAkNOMQswCQYDVQQIEwJaSjELMAkG
A1UEBxMCWUQxFTATBgNVBAoTDEZvcnQtRnVuc3RvbjEdMBsGA1UECxMUTXlPcmdh
bml6YXRpb25hbFVuaXQxCzAJBgNVBAMTAmNhMRAwDgYDVQQpEwdFYXN5UlNBMSEw
HwYJKoZIhvcNAQkBFhJtZUBteWhvc3QubXlkb21haW6CCQDDD6YC0zzwAjAMBgNV
HRMEBTADAQH/MA0GCSqGSIb3DQEBCwUAA4GBAFIVIotU7ClrZLLxuLmC9N5JE0OQ
wGNj6G0DmzU0GOyM5SLCgTenbtFL+eIEkw1/Wbic8IGRG9t3K3V0GAE/KAAtwApE
F2+S6L8A3ienrvwjRzdlKMv9h3QuEp/XJD21T9kZKosPR4E2QBWgVCwO4Vba7fd/
FKUvAiakVNWFWSiY
-----END CERTIFICATE-----
</ca>
key-direction 1
<tls-auth>
#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
a340b1145aba5c5c1513fbd3ebc50a12
0b0a10f8f4250d4cba67db9275e1a3fb
f081af8e0f8ae8e512237428eb491fb8
d36b05cb4b41eb22eecd4f7577c6f280
2e3debd3676865cbaacf3d40b60ee28b
3b0302096aafc075f215488f0c4d4a27
7e9d5af5d4c4085b559d790f1a78ded7
f2c0488026bf6a15695b89c04119a86f
481025d521e70f5755f8b2708699d751
3f53b92555e782b0335b4ce58aca2c48
a43b3a798b19736ca3d57ef84b6d6768
0a13dc9cca1562e344570e30d4c93ca1
eacb2a4a52d8292dbe99146d4ae60872
8a78e2340c49da76e1894951c7e9c616
70aa3decd9961c5cdc8ca11d3cc3e6aa
4c50c7cf2743e858d6de1a03a9f23c31
-----END OpenVPN Static key V1-----
</tls-auth>">/var/www/html/test.ovpn
	echo "==========================================================================
                          博雅-DALO 稳定版 安装完成                          
																		 
		以下信息将自动保存到/root/info.txt文件中	
                                                                         
                            博雅-DALO服务器信息							
                                                                         
                   查询流量地址：( "$IP":"$cxlldk" )                     
                   APP 下载地址：( "$IP":"$appjiemian" )脑残勿用此链接   
                   后台管理地址：( "$IP":"$lkdk"/"$wenjian" )            
                   线路模板地址：( "$IP":"$lkdk"/test.ovpn )			
                   后台管理账号: "$administrator" 密码: "$boya123"      
                   数据库  账号: root  密码: "$sqladmin"                 
                           重启VPN命令：vpn                               
温馨提示下 这个脚本443 440 3389 1026 53 1194 都开了的！别瞎鸡巴弄了！我懒得售后啊
==========================================================================">/root/info.txt
	echo "请回车重启服务器使DALO流控安装完成。"
	read
	reboot
}


Fill_in_installation_information()
{
	clear
	read -p "请输入后台端口(请填写7000以上的端口!默认8888):" lkdk
	if [ -z "$lkdk" ];then
	lkdk=8888
	fi
	
	read -p "请输入后台账号(默认administrator):" administrator
	if [ -z "$administrator" ];then
	administrator=administrator
	fi

	read -p "请输入后台密码(默认radius):" boya123
	if [ -z "$boya123" ];then
	boya123=radius
	fi
	
	read -p "请输入数据库密码(默认newpass)六位数以上！:" sqladmin
	if [ -z "$sqladmin" ];then
	sqladmin=newpass
	fi
	
	read -p "请输入后台管理员文件夹(默认admin):" wenjian
	if [ -z "$wenjian" ];then
	wenjian=admin
	fi

	read -p "查询流量端口(默认5000):" cxlldk
	if [ -z "$cxlldk" ];then
	cxlldk=5000
	fi
	
	read -p "APP下载端口(默认555):" appjiemian
	if [ -z "$appjiemian" ];then
	appjiemian=555
	fi
	
	
	Select_resource_host
	
	Check_ports
	
	return;
}





Check_ports()
{
	
	if [[ $lkdk = $cxlldk ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = $appjiemian ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = $appjiemian ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	fi

	if [[ $lkdk = 80 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 8080 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 53 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 138 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 28080 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 1194 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 445 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 50000 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 50001 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 50002 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 42 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 90 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 135 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 139 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 593 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 1025 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 1068 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 1434 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 1723 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 3128 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 4444 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 8083 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 8443 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 443 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 440 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 3389 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 21 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 3306 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 3311 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 3322 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 3333 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 3344 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $lkdk = 3355 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	fi

	if [[ $cxlldk = 80 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 8080 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 53 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 138 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 28080 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 1194 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 445 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 50000 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 50001 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 50002 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 42 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 90 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 135 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 139 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 593 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 1025 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 1068 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 1434 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 1723 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 3128 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 4444 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 8083 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 8443 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 443 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 440 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 3389 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 21 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 3306 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 3311 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 3322 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 3333 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 3344 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $cxlldk = 3355 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	fi
	
	if [[ $appjiemian = 80 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 8080 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 53 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 138 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 28080 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 1194 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 445 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 50000 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 50001 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 50002 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 42 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 90 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 135 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 139 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 593 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 1025 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 1068 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 1434 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 1723 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 3128 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 4444 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 8083 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 8443 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 443 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 440 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 3389 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 21 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 3306 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 3311 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 3322 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 3333 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 3344 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	elif [[ $appjiemian = 3355 ]];then
	echo "请重新运行脚本！端口设置错误！请换一个！"
	exit;
	fi
	
	return;
}



function Start_all_programs() {
	cat >> /etc/hosts <<EOF
#######################移动#######################
192.168.255.1 wap.gx.10086.cn
192.168.255.1 wap.sh.10086.cn
192.168.255.1 wap.hb.10086.cn
192.168.255.1 wap.hb.10086.cn
192.168.255.1 wap.hn.10086.cn
192.168.255.1 wap.bj.10086.cn
192.168.255.1 wap.gd.10086.cn
192.168.255.1 wap.jx.10086.cn
192.168.255.1 wap.cq.10086.cn
192.168.255.1 wap.zj.10086.cn
192.168.255.1 wap.yn.10086.cn
192.168.255.1 wap.sc.10086.cn
192.168.255.1 wap.sn.10086.cn
192.168.255.1 wap.sd.10086.cn
192.168.255.1 wap.jx.10086.cn
192.168.255.1 wap.js.10086.cn
192.168.255.1 wap.hl.10086.cn
192.168.255.1 wap.hi.10086.cn
192.168.255.1 wap.gz.10086.cn
192.168.255.1 wap.gs.10086.cn
192.168.255.1 wap.fj.10086.cn
192.168.255.1 wap.sz.10086.cn
192.168.255.1 wap.ah.10086.cn
192.168.255.1 wap.fj.10086.cn
192.168.255.1 wap.ln.10086.cn
192.168.255.1 wap.jl.10086.cn
192.168.255.1 wap.tj.10086.cn
192.168.255.1 wap.nx.10086.cn
192.168.255.1 wap.ah.10086.cn
192.168.255.1 wap.sx.10086.cn
192.168.255.1 wap.xj.10086.cn
192.168.255.1 wap.he.10086.cn
192.168.255.1 wap.ha.10086.cn
192.168.255.1 wap.xz.10086.cn
192.168.255.1 wap.qh.10086.cn
192.168.255.1 wap.ll.10086.cn

192.168.255.1 wap.gx.chinamobile.com
192.168.255.1 wap.sh.chinamobile.com
192.168.255.1 wap.hb.chinamobile.com
192.168.255.1 wap.hb.chinamobile.com
192.168.255.1 wap.hn.chinamobile.com
192.168.255.1 wap.bj.chinamobile.com
192.168.255.1 wap.gd.chinamobile.com
192.168.255.1 wap.jx.chinamobile.com
192.168.255.1 wap.cq.chinamobile.com
192.168.255.1 wap.zj.chinamobile.com
192.168.255.1 wap.yn.chinamobile.com
192.168.255.1 wap.sc.chinamobile.com
192.168.255.1 wap.sn.chinamobile.com
192.168.255.1 wap.sd.chinamobile.com
192.168.255.1 wap.jx.chinamobile.com
192.168.255.1 wap.js.chinamobile.com
192.168.255.1 wap.hl.chinamobile.com
192.168.255.1 wap.hi.chinamobile.com
192.168.255.1 wap.gz.chinamobile.com
192.168.255.1 wap.gs.chinamobile.com
192.168.255.1 wap.fj.chinamobile.com
192.168.255.1 wap.sz.chinamobile.com
192.168.255.1 wap.ah.chinamobile.com
192.168.255.1 wap.fj.chinamobile.com
192.168.255.1 wap.ln.chinamobile.com
192.168.255.1 wap.jl.chinamobile.com
192.168.255.1 wap.tj.chinamobile.com
192.168.255.1 wap.nx.chinamobile.com
192.168.255.1 wap.ah.chinamobile.com
192.168.255.1 wap.sx.chinamobile.com
192.168.255.1 wap.xj.chinamobile.com
192.168.255.1 wap.he.chinamobile.com
192.168.255.1 wap.ha.chinamobile.com
192.168.255.1 wap.xz.chinamobile.com
192.168.255.1 wap.qh.chinamobile.com

192.168.255.1 www.nx.10086.cn
192.168.255.1 c22.cmvideo.cn
192.168.255.1 img1.shop.10086.cn 
192.168.255.1 wap.chinamobile.com
192.168.255.1 rd.go.10086.cn
192.168.255.1 shoujibao.net
192.168.255.1 migumovie.lovev.com
192.168.255.1 wap.cmvideo.cn
192.168.255.1 wap.cmread.com
192.168.255.1 wap.hetau.com
192.168.255.1 a.10086.cn 
192.168.255.1 touch.10086.cn
192.168.255.1 wap.jf.10086.cn
192.168.255.1 music.migu.cn
192.168.255.1 wap.10086.cn
192.168.255.1 m.miguvideo.com
192.168.255.1 mmsc.monternet.com
192.168.255.1 a.mll.migu.cn
192.168.255.1 m.t.17186.cn
192.168.255.1 gslb.miguvod.lovev.com
192.168.255.1 miguvod.lovev.com
192.168.255.1 data.10086.cn
192.168.255.1 freetyst.mll.migu.cn
192.168.255.1 mll.migu.cn
192.168.255.1 www.baidu.com
192.168.255.1 dlsdown.mll.migu.cn
192.168.255.1 p.mll.migu.cn
192.168.255.1 www.cmpay.com
192.168.255.1 jl.12530.com
192.168.255.1 dspserver.ad.cmvideo.cn
192.168.255.1 strms.free.migudm.cn
192.168.255.1 app.free.migudm.cn
192.168.255.1 wap.monternet.com
192.168.255.1 www.sc.chinamobile.com
192.168.255.1 www.gx.chinamobile.com
192.168.255.1 www.jl.chinamobile.com
192.168.255.1 sdc.10086.cn
192.168.255.1 monternet.sx.chinamobile.com
192.168.255.1 ws.gf.com.cn
192.168.255.1 dlsdown.mll.migu.cn
192.168.255.1 img1.shop.10086.cn
192.168.255.1 wapnews.i139.cn
192.168.255.1 freetyst.mll.migu.cn
192.168.255.1 dlsdown.mll.migu.cn
192.168.255.1 search.10086.cn
192.168.255.1 clientdispatch.10086.cn
192.168.255.1 hf.mm.10086.cn
192.168.255.1 yyxx.10086.cn
192.168.255.1 xxyy.10086.cn.com
192.168.255.1 index.12530.com
192.168.255.1 service.ah.10086.cn
192.168.255.1 i.stat.nearme.com.cn
192.168.255.1 wap.clientdispatch.10086.cn
192.168.255.1 allctc.m.shouji.360tpcdn.com
192.168.255.1 jf.10086.cn
192.168.255.1 wifi.pingan.com
192.168.255.1 vod.hcs.cmvideo.cn
192.168.255.1 mm.i139.cn
192.168.255.1 bbs.clzjwl.com
192.168.255.1 adxserver.ad.cmvideo.cn
192.168.255.1 vod.hcs.cmvideo.cn
192.168.255.1 www.nx.10086.cn
192.168.255.1 m.cmvideo.cn
192.168.255.1 5.mm-img.mmarket.com
192.168.255.1 u5.mm-img.mmarket.com
192.168.255.1 service.gx.10086.cn
192.168.255.1 sdc2.10086.cn
192.168.255.1 login.10086.cn
192.168.255.1 login.10086.cn
192.168.255.1 login.10086.cn
192.168.255.1 beacons5.gvt3.com
192.168.255.1 wlanwm.12530.com
192.168.255.1 12580wap.10086.cn
192.168.255.1 imusic.wo.com.cn
192.168.255.1 3g.ha.i139.cn
192.168.255.1 kf.migu.cn
192.168.255.1 pingma.qq.com
192.168.255.1 game.eve.mdt.qq.com
192.168.255.1 gfres.a.migu.cn
192.168.255.1 sc.chinamobilesz.com
192.168.255.1 m.cmvideo.com
192.168.255.1 jf-asset1.10086.cn
192.168.255.1 www.139ylh.com
192.168.255.1 wap.wxcs.cn
192.168.255.1 www.wxcs.cn
192.168.255.1 webpay.migu.cn
192.168.255.1 share.migu.cn
192.168.255.1 wap.js.10086.co
192.168.255.1 www.139ylh.com
192.168.255.1 www.139ylh.com
192.168.255.1 ml.qishall.cn
192.168.255.1 hdh.10086.cn
192.168.255.1 hm.baidu.com
192.168.255.1 cms.buslive.cn
192.168.255.1 img01.netvan.cn
192.168.255.1 erkuailife.com
192.168.255.1 caiyunyoupin.com
192.168.255.1 real.caiyunyoupin.com
192.168.255.1 gmu.g188.net
192.168.255.1 gamepie.g188.net
192.168.255.1 zabbix.186students.com
192.168.255.1 download.cmgame.com
192.168.255.1 static.cmgame.com
192.168.255.1 g.10086.cn
192.168.255.1 apk.miguvideo.com
192.168.255.1 movie.miguvideo.com
192.168.255.1 vod.gslb.cmvideo.cn
192.168.255.1 dl.wap.dm.10086.cn
192.168.255.1 nginx.zgyd.diyring.cc
192.168.255.1 file.kuyinyun.com
192.168.255.1 file.diyring.cc
192.168.255.1 www.webdissector.com
192.168.255.1 dspserver.ad.cmvideo.cn
192.168.255.1 recv-wd.gridsumdissector.com
192.168.255.1 static.gridsumdissector.com
192.168.255.1 

192.168.255.1 218.207.208.30
192.168.255.1 218.200.230.40
192.168.255.1 183.224.41.139
192.168.255.1 183.224.41.138
192.168.255.1 221.181.41.20
192.168.255.1 117.136.139.32
192.168.255.1 182.254.44.248
192.168.255.1 223.111.8.14
192.168.255.1 218.207.75.6
192.168.255.1 183.203.36.7
192.168.255.1 221.180.144.111
192.168.255.1 192.168.200.212
192.168.255.1 222.186.151.18
211.136.165.53 211.136.165.53
192.168.255.1 221.181.41.36
192.168.255.1 10.238.233.182
192.168.255.1 211.138.195.197
192.168.255.1 221.178.251.33
192.168.255.1 221.179.219.138
192.168.255.1 117.136.139.4
192.168.255.1 117.139.217.198
192.168.255.1 117.131.17.147
192.168.255.1 221.181.100.104
192.168.255.1 112.4.20.188
#######################联通#######################
192.168.255.1 wap.10010.com
192.168.255.1 box.10155.com
192.168.255.1 mob.10010.com
192.168.255.1 wap.10155.com
192.168.255.1 www.10155.com
192.168.255.1 wap.17wo.com
192.168.255.1 mmsc.myuni.com.cn
192.168.255.1 m.iread.wo.com.cn
192.168.255.1 iread.wo.com.cn
192.168.255.1 m.client.10010.com
192.168.255.1 m.10010.com
192.168.255.1 uac.10010.com
192.168.255.1 mv.wo.com.cn
192.168.255.1 zjw.mmarket.com
192.168.255.1 xiami.gzproxy.10155.com
192.168.255.1 music163.gzproxy.10155.host
192.168.255.1 wap.17wo.cn
192.168.255.1 3gwap.10010.com
192.168.255.1 love9999.top
192.168.255.1 www.10010.com
192.168.255.1 kugou.gzproxy.10155.com
192.168.255.1 u.3gtv.net
192.168.255.1 szextshort.weixin.qq.com
192.168.255.1 game.eve.mdt.qq.com
192.168.255.1 w.zj165.com
192.168.255.1 sales.wostore.cn
192.168.255.1 res.mall.10010.cn
192.168.255.1 wap.gs.10010.com
192.168.255.1 1utv.bbn.com.cn
192.168.255.1 utv.bbn.com.cn
192.168.255.1 k.10010.com
192.168.255.1 mp.weixin.qq.com
192.168.255.1 ssl.zc.qq.com
192.168.255.1 wap.tv.wo.com.cn
192.168.255.1 chat.gd10010.cn
192.168.255.1 m.t.17186.cn
192.168.255.1 sales.wostore.cn
#######################电信#######################
192.168.255.1 ltetp.tv189.cn
192.168.255.1 dl.music.189.cn
192.168.255.1 cdn.4g.play.cn
192.168.255.1 wapzt.189.cn
192.168.255.1 ltetptv.189.com
192.168.255.1 ltetp.tv189.com
192.168.255.1 iting.music.189.cn
192.168.255.1 yangqitingshu.musicway.cn
192.168.255.1 allctc.m.shouji.boyer3970.cn
192.168.255.1 4galbum.musicway.cn
192.168.255.1 h5.nty.tv189.com
192.168.255.1 4gmv.music.189.cn
192.168.255.1 allctc.m.shouji.360tpcdn.com
192.168.255.1 login.189.cn
192.168.255.1 vod3.nty.tv189.cn
192.168.255.1 yinyuetai.musicway.cn
192.168.255.1 111.206.135.39
192.168.255.1 www.v.wo.cn
192.168.255.1 v.wo.cn
192.168.255.1 m.cctv4g.com
192.168.255.1 pic01.v.vnet.mobi
192.168.255.1 cdn.bootcss.com
192.168.255.1 m.tv189.com
192.168.255.1 h5.tv189.com
192.168.255.1 lteams.tv189.com
192.168.255.1 api.tv189.com
192.168.255.1 118.85.193.208
192.168.255.1 h.tv189.com
192.168.255.1 ycj.tv189.com
127.0.0.1 `hostname`
EOF

	echo 'setenforce 0
sysctl -w net.ipv4.ip_forward=1
ulimit -n 65535
killall -9 radiusd
killall -9 squid
killall -9 haproxy
killall -9 openvpn
killall -9 time.sh
#killall -9 mproxy
squid -z
time.sh &
setsebool httpd_can_network_connect 1
rm -rf /etc/openvpn/*.txt /etc/openvpn/ccd*/*
service mysqld restart
service httpd restart
service radiusd restart
service dnsmasq restart
service openvpn restart
service haproxy restart
service squid restart
service iptables restart

setenforce 1
killall mproxy >/dev/null 2>&1
mproxy -l 8080 -d >/dev/null 2>&1
mproxy -l 138 -d >/dev/null 2>&1
mproxy -l 137 -d >/dev/null 2>&1
mproxy -l 53 -d >/dev/null 2>&1
mproxy -l 524 -d >/dev/null 2>&1
mproxy -l 1026 -d >/dev/null 2>&1
mproxy -l 8081 -d >/dev/null 2>&1
mproxy -l 180 -d >/dev/null 2>&1
mproxy -l 53 -d >/dev/null 2>&1
mproxy -l 351 -d >/dev/null 2>&1
mproxy -l 366 -d >/dev/null 2>&1
mproxy -l 28080 -d >/dev/null 2>&1
sysctl -p >/dev/null 2>&1'>/sbin/vpn
chmod -R 0777 /sbin/mproxy
chmod -R 0777 /sbin/vpn
chmod -R 0777 /sbin/time.sh
vpn
}


Install_Daloradius()
{
	echo "正在检查系统信息，请等待..."
	Inspection_before_installation
	Fill_in_installation_information
	Install_System_environment
	Install_Firewall
	Install_MySQL
	Install_Radius
	Install_OpenVPN
	Install_Squid
	Install_Haproxy
	Install_dnsmasq
	Install_Apache
	Start_all_programs
	Install_Done
	
	return;
}

Main()
{
	clear
	echo ""
	echo -e "\033[1;32m" 
	echo "=========================================================================="
	echo "                       博雅-DALO 稳定版 安装开始                          "
	echo "                                                                          "
	echo "                            QQ：2223139086                                "
	echo "                       Welcome to use this program                        "
	echo "                       2023.02.14由Shirley优化修复!                       "
	echo "                                                                          "
	echo "                                         版权所有 博雅Dalo                "
	echo "=========================================================================="
	echo -e "\033[0m"
	sleep 2
	echo -e "\033[1;33m正在检测您的服务器IP地址！\033[0m"
	IP=`wget http://members.3322.org/dyndns/getip -O - -q ; echo`;
	if [ "$IP" = "" ]; then
		#空白
		echo -e "\033[1;31m我们无法检测到您的IP地址，请联系管理员处理~\033[0m"
		exit 1
	else
		#已获取到信息
		echo -e "\033[1;34m检测到您的IP为：\033[0m\033[1;32m"$IP"\033[0m \033[1;34m如不正确请立刻停止并联系管理员，回车继续！\033[0m"
		read
		Program_list
	fi
}


Connect_to_cloud_database()
{
	if [ ! -f /etc/raddb/sql.conf ]; then
		echo "您好像并没有安装freeradius"
		echo "程序结束"
		exit 0;
	fi

	if [ ! -d /var/www/html ]; then
		echo "您好像并没有安装博雅DALO"
		echo "程序结束"
		exit 0;
	fi
	
	clear
	read -p "请输入云数据库地址:" ysjkdz
	if [ -z "$ysjkdz" ];then
	ysjkdz=localhost
	fi
	
	read -p "请输入云数据库端口:" ysjkdk
	if [ -z "$ysjkdk" ];then
	ysjkdk=3306
	fi
	
	read -p "请输入云数据库账号:" ysjkzh
	if [ -z "$ysjkzh" ];then
	ysjkzh=root
	fi
	
	read -p "请输入云数据库密码:" ysjkmm
	if [ -z "$ysjkmm" ];then
	ysjkmm=root
	fi
	
	read -p "请输入daloradius管理后台文件名:" guanliyuanwenjianming
	if [ -z "$guanliyuanwenjianming" ];then
	guanliyuanwenjianming=admin
	fi
	echo "提示:请自行讲数据导入云数据库中~"
	echo "提示:不会导入可联系管理导入~"
	mysql -h${ysjkdz} -P${ysjkdk} -u${ysjkzh} -p${ysjkmm} -e "create database radius;use radius;set names utf8;source /etc/raddb/sql/freeradius.sql"
	sed -i 's/server = localhost/server = '$ysjkdz'/g' /etc/raddb/sql.conf
	sed -i 's/#port = 3306/port = '$ysjkdk'/g' /etc/raddb/sql.conf
	sed -i 's/login = radius/login = '$ysjkzh'/g' /etc/raddb/sql.conf
	sed -i 's/hehe123/'$ysjkmm'/g' /etc/raddb/sql.conf
	sed -i "s/['CONFIG_DB_HOST'] = 'localhost'/['CONFIG_DB_HOST'] = '"$ysjkdz"'/g" /var/www/html/${guanliyuanwenjianming}/library/daloradius.conf.php
	sed -i "s/['CONFIG_DB_PORT'] = '3306'/['CONFIG_DB_PORT'] = '"$ysjkdk"'/g" /var/www/html/${guanliyuanwenjianming}/library/daloradius.conf.php
	sed -i "s/['CONFIG_DB_USER'] = 'radius'/['CONFIG_DB_USER'] = '"$ysjkzh"'/g" /var/www/html/${guanliyuanwenjianming}/library/daloradius.conf.php
	sed -i "s/['CONFIG_DB_PASS'] = 'hehe123'/['CONFIG_DB_PASS'] = '"$ysjkmm"'/g" /var/www/html/${guanliyuanwenjianming}/library/daloradius.conf.php
	sed -i "s/mysql -uradius -phehe123/mysql -h"$ysjkdz" -P"$ysjkdk" -u"$ysjkzh" -p"$ysjkmm"/g" /sbin/time.sh

	echo "云数据库地址为:"$ysjkdz""
	echo "云数据库端口为:"$ysjkdk""
	echo "云数据库账号为:"$ysjkzh""
	echo "云数据库密码为:"$ysjkmm""
	vpn
	echo "已完成对接，如需修改流量卫士数据库请自行前往/var/www/html/config.php修改！"
	exit
}


Backup_data()
{

rm -rf /var/www/html/beifen.html
cat >> /var/www/html/beifen.html <<EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">  
<html xmlns="http://www.w3.org/1999/xhtml">  
<head>  
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />  
<title>Image Rollover with CSS</title>  
<style type="text/css" media="screen">  
a.button { background:url(rss-feed-img.png) repeat 0px 0px; width: 123px; height: 44px; display: block; }  
a.button span { display: none; }  
a.button:hover {
	background: url(rss-feed-img.png) repeat 0px -44px;
	text-align: center;
	font-size: 16px;
}  
.button span {
	font-size: 12px;
}
</style>  
</head>  
<body>
<blockquote>
  <blockquote>
    <blockquote>
      <blockquote>
        <blockquote>
          <p><strong><a href="radius.tar.gz" download="radius.tar.gz"class="button"><span>RSS Feeds</span>&#28857;&#25105;&#19979;&#36733;&#25968;&#25454;</a></strong>  
          </p>
        </blockquote>
      </blockquote>
    </blockquote>
  </blockquote>
</blockquote>
</body>  
</html>
EOF
mysqldump -uradius -phehe123 radius > radius.sql
tar zcvf radius.tar.gz radius.sql
rm -rf radius.sql
mv radius.tar.gz /var/www/html
chmod -R 0777 /var/www/html/beifen.html
chmod -R 0777 /var/www/html/radius.tar.gz
echo "已经为您完成备份！"
read -p "请输入后台端口号(必须输入！):" lkdk
if [ -z "$lkdk" ];then
	lkdk=8888
else
	echo ""
fi
echo "请在浏览器输入下方网址进行下载您的数据！"
echo "下载数据方法1：http://"$IP":"$lkdk"/beifen.html"
echo "下载数据方法2：http://"$IP":"$lkdk"/radius.tar.gz"
echo "下载数据方法3：到服务器目录: /var/www/html/radius.tar.gz"
sed -i "s/Deny from all/Allow from all/g" /etc/httpd/conf/httpd.conf
setenforce 0
service httpd restart
echo "下载完成之后请回车进行文件删除！"
read
service httpd restart
rm -rf /var/www/html/radius.tar.gz
exit

}


System_load()
{
clear

gonggao="+---------------------------------------------------------------------+
+                   正在运行自动联防脚本！                            +
+                                                                     +
+          By 情韵  QQ群 475605707  官网 www.52hula.cn                     +
+                                                                     +
+---------------------------------------------------------------------+"
moshi="---------------------------------------------------------
请选择您要进入的安装模式，输入相应的序号后回车
---------------------------------------------------------

---------------------------------------------------------
1、主机模式（在主机运行）
2、子机模式（在子机运行）"
echo "$gonggao"
echo "$moshi"
echo
echo "请选择[1-2]: "
read lf
if [[ $lf == 1 ]];then
read -p "请输入要负载的子机数量" n
m=0
while [ $m -lt $n ]
do
m=$[$m+1]
read -p "请输入第"$m"子机IP:" nmpport
cat >> /etc/raddb/clients.conf <<EOF
client $nmpport {
secret = testing123
shortname = $nmpport
ipaddr = $nmpport
}
EOF
done
service radiusd restart
elif [[ $lf == 2 ]];then 
cp=`grep 'name=localhost' /etc/openvpn/radiusplugin_1.cnf`
if [ -z "$cp" ];then
echo "您好像并没有安装博雅DALO"
echo "程序结束"
exit 0;
else
echo
fi
read -p "请输入主机IP:" nmpport
sed s/name=localhost/name="$nmpport"/g /etc/openvpn/radiusplugin* -i
service openvpn restart
else 
echo "输入错误，请重新运行脚本"
exit 0;
fi
echo "操作已完成...."
exit 0;

}

Install_Daloradius_DingD_localhost(){
	clear
	echo "使用说明："
	echo "服务器后台端口(就是你出卡后台的端口~如果是默认的那就是8888)"
	echo "然后搭建中有什么问题,吧服务器发给情韵解决！不认识我的你就认栽吧！"
	
	read -p "请输入当前服务器后台端口(默认8888):" dingd_houtai_prot
	if [ -z "$dingd_houtai_prot" ];then
	dingd_houtai_prot=8888
	fi
	
	Select_resource_host
	
	cd /root
	rm -rf /var/www/html/*
	wget ${Download_Host}/new_llws.zip
	unzip -o new_llws.zip -d /var/www/html
	sed -i "s/111.231.54.94/${IP}/g" /var/www/html/vpndata.sql;	
	mysql -uradius -phehe123 radius < /var/www/html/vpndata.sql
	mysql -uradius -phehe123 'use radius;alter table radcheck add note_id int(11) NOT NULL;alter table line add `order` int(11) NOT NULL DEFAULT '0';alter table line modify `order` int(11) after label;'
	echo "#!/bin/sh
	for((;;))
	do
		echo `curl -s http://localhost:${dingd_houtai_prot}/app_api/api.php?act=user_test`;
		sleep 7200
	done">/sbin/bydaloll.sh
	
	echo "${RANDOM}" > /var/www/auth_key.access
	chmod -R 0777 /sbin/bydaloll.sh
	nohup /sbin/bydaloll.sh &
	nohup /sbin/time.sh &
	kouling=`cat /var/www/auth_key.access`;
	
	if [ ! -n "$dingd_host" ] ;then
		dingd_host=localhost
	fi
	if [ ! -n "$dingd_port" ] ;then
		dingd_port=3306
	fi
	if [ ! -n "$dingd_user" ] ;then
		dingd_user=radius
	fi
	if [ ! -n "$dingd_pass" ] ;then
		dingd_pass=hehe123
	fi
	
	rm -rf /var/www/html/config.php
	echo '
<?php
/* 本文件由系统自动生成 如非必要 请勿修改 */
define("_host_","'$dingd_host'");
define("_user_","'$dingd_user'");
//define("_pass_","ping");
define("_pass_","'$dingd_pass'");
define("_port_","'$dingd_port'");
define("_ov_","radius");
define("_openvpn_","openvpn");
define("_iuser_","iuser");
define("_ipass_","pass");
define("_isent_","isent");
define("_irecv_","irecv");
define("_starttime_","starttime");
define("_endtime_","endtime");
define("_maxll_","maxll");
define("_other_","dlid,tian");
define("_i_","i");
//本地口令'>/var/www/html/config.php
	
	chmod -R 0777 /var/www/html/
	
	clear
	echo "已安装完成"
	echo
	echo "在此声明!后台源码非博雅原创!我们只是修改了一些地方!勿喷!"
	echo
	echo "流量卫视后台地址：http://"$IP":"$dingd_houtai_prot"/admin"
	echo
	echo "流量卫视后台账号：admin  后台密码：admin  口令: "$kouling""
	echo
	echo "daloradius后台地址：http://"$IP":"$dingd_houtai_prot"/daloradius"
	echo
	echo "苹果下载线路地址：http://"$IP":"$dingd_houtai_prot"/user"
	echo
	echo "如果需要更换流量卫视数据库请修改文件/var/www/html/config.php"
	echo
	echo "APP请进博雅总群下载!自己手动对接下~后续再更新自动对接的~!"
	vpn
	exit 0;
}

Install_Daloradius_DingD_Cloud()
{
	clear
	echo "使用说明："
	echo "服务器后台端口(就是你出卡后台的端口~如果是默认的那就是8888)"
	echo "云数据库地址:"
	echo "(比如说腾讯云的开启远程访问后有个地址去掉端口和冒号！实在不懂就会车！回车就变成了本地了！)"
	echo "云数据库端口:和上面一样，腾讯云地址后面那个不要带冒号！实在不懂就回车！回车就变成了本地了！"
	echo "云数据库账号:(这个不用我说了吧~不懂就回车变本地的吧~)"
	echo "云数据库密码:(这个不用我说了吧~不懂就回车变本地的吧~)"
	echo "然后搭建中有什么问题,吧服务器发给情韵解决！不认识我的你就认栽吧！"
	read -p "请输入当前服务器后台端口(默认8888):" dingd_houtai_prot
	if [ -z "$dingd_houtai_prot" ];then
	dingd_houtai_prot=8888
	fi
	
	read -p "请输入云数据库地址(请勿带端口！):" dingd_host
	if [ -z "$dingd_host" ];then
	dingd_host=localhost
	fi

	read -p "请输入云数据库端口:" dingd_port
	if [ -z "$dingd_port" ];then
	dingd_port=3306
	fi
	
	read -p "请输入云数据库账号:" dingd_user
	if [ -z "$dingd_user" ];then
	dingd_user=radius
	fi
	
	read -p "请输入云数据库密码:" dingd_pass
	if [ -z "$dingd_pass" ];then
	dingd_pass=hehe123
	fi
	
	Select_resource_host
	
	cd /root
	rm -rf /var/www/html/*
	wget ${Download_Host}/new_llws.zip
	unzip -o new_llws.zip -d /var/www/html
	sed -i "s/111.231.54.94/${IP}/g" /var/www/html/vpndata.sql;	
	mysql -h${dingd_host} -P${dingd_port} -u${dingd_user} -p${dingd_pass} radius < /var/www/html/vpndata.sql
	mysql -h${dingd_host} -P${dingd_port} -u${dingd_user} -p${dingd_pass} 'use radius;alter table radcheck add note_id int(11) NOT NULL;alter table line add `order` int(11) NOT NULL DEFAULT '0';alter table line modify `order` int(11) after label;'
	echo "#!/bin/sh
	for((;;))
	do
		echo `curl -s http://localhost:${dingd_houtai_prot}/app_api/api.php?act=user_test`;
		sleep 7200
	done">/sbin/bydaloll.sh
	
	echo "${RANDOM}" > /var/www/auth_key.access
	chmod -R 0777 /sbin/bydaloll.sh
	nohup /sbin/bydaloll.sh &
	nohup /sbin/time.sh &
	kouling=`cat /var/www/auth_key.access`;
	
	if [ ! -n "$dingd_host" ] ;then
		dingd_host=localhost
	fi
	if [ ! -n "$dingd_port" ] ;then
		dingd_port=3306
	fi
	if [ ! -n "$dingd_user" ] ;then
		dingd_user=radius
	fi
	if [ ! -n "$dingd_pass" ] ;then
		dingd_pass=hehe123
	fi
	
	rm -rf /var/www/html/config.php
	echo '
<?php
/* 本文件由系统自动生成 如非必要 请勿修改 */
define("_host_","'$dingd_host'");
define("_user_","'$dingd_user'");
//define("_pass_","ping");
define("_pass_","'$dingd_pass'");
define("_port_","'$dingd_port'");
define("_ov_","radius");
define("_openvpn_","openvpn");
define("_iuser_","iuser");
define("_ipass_","pass");
define("_isent_","isent");
define("_irecv_","irecv");
define("_starttime_","starttime");
define("_endtime_","endtime");
define("_maxll_","maxll");
define("_other_","dlid,tian");
define("_i_","i");
//本地口令'>/var/www/html/config.php
	
	sed -i "s/['CONFIG_DB_HOST'] = 'localhost'/['CONFIG_DB_HOST'] = '"$dingd_host"'/g" /var/www/html/daloradius/library/daloradius.conf.php
	sed -i "s/['CONFIG_DB_PORT'] = '3306'/['CONFIG_DB_PORT'] = '"$dingd_port"'/g" /var/www/html/daloradius/library/daloradius.conf.php
	sed -i "s/['CONFIG_DB_USER'] = 'radius'/['CONFIG_DB_USER'] = '"$dingd_user"'/g" /var/www/html/daloradius/library/daloradius.conf.php
	sed -i "s/['CONFIG_DB_PASS'] = 'hehe123'/['CONFIG_DB_PASS'] = '"$dingd_pass"'/g" /var/www/html/daloradius/library/daloradius.conf.php
	
	chmod -R 0777 /var/www/html/
	
	clear
	echo "已安装完成"
	echo
	echo "在此声明!后台源码非博雅原创!我们只是修改了一些地方!勿喷!"
	echo
	echo "流量卫视后台地址：http://"$IP":"$dingd_houtai_prot"/admin"
	echo
	echo "流量卫视后台账号：admin  后台密码：admin 口令: "$kouling""
	echo
	echo "daloradius后台地址：http://"$IP":"$dingd_houtai_prot"/daloradius"
	echo
	echo "苹果下载线路地址：http://"$IP":"$dingd_houtai_prot"/user"
	echo
	echo "如果需要更换流量卫视数据库请修改文件/var/www/html/config.php"
	echo
	echo "APP请进博雅总群下载!自己手动对接下~后续再更新自动对接的~!"
	vpn
	exit 0;
	
	
}



Install_Daloradius_DingD()
{
	clear
	echo "数据库连接方式: "
	echo
	echo "1、本地数据库"
	echo "2、云数据库"
	echo
	echo "请选择[1-2]: "
	read DingDAPP_Option

	if [[ $DingDAPP_Option == 1 ]];then
	Install_Daloradius_DingD_localhost
	install_php
	Modify_dingd
	end_dingd
	sleep 3
	fi

	if [[ $DingDAPP_Option == 2 ]];then
	Install_Daloradius_DingD_Cloud
	install_php
	Modify_dingd
	end_dingd
	sleep 3
	fi
	
	echo "输入错误！请重新运行脚本！"
	exit 0;
}


Program_list()
{
	
	clear
	echo ""
	echo -e "\033[31m \033[05m 请根据下方提示输入相对应序号 \033[0m"
	echo ""
	echo -e "1、安装博雅DALO稳定版"
	echo -e "2、对接云数据库"
	echo -e "3、备份MySQL(Radius)数据"
	echo -e "4、DALO联防脚本(系统负载)"
	echo -e "5、安装DALO流量卫士(FAS版)"
	echo -e "6、退出脚本"
	echo ""
	echo -e "请选择[1-6]: "
	read k

	if [[ $k == 1 ]];then
		Install_Daloradius
		exit 0;
	fi

	
	if [[ $k == 2 ]];then
		Connect_to_cloud_database
		exit 0;
	fi

	if [[ $k == 3 ]];then
		Backup_data
		exit 0;
	fi
	
	if [[ $k == 4 ]];then
		System_load
		exit 0;
	fi


	if [[ $k == 5 ]];then
		Install_Daloradius_DingD
		exit 0;
	fi
	
	
	if [[ $k == 6 ]];then
		echo "感谢使用，再见！"
		exit 0;
	fi
	
	
	echo "输入错误！请重新运行脚本！"
	exit 0;




}


Main
exit 0;

