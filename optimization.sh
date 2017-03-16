#!/bin/bash
##############################################################
# Author: liukj
# Created Time : 2017-03-13
# Description: Linux system initialization
##############################################################
. /etc/init.d/functions

# Defined result function
function Msg() {
        if [ $? -eq 0 ];then
          action "$1" /bin/true
        else
          action "$1" /bin/false
        fi
}

# Defined IP function
function ConfigIP() {
        Suffix=`ifconfig eth0|awk -F "[ .]+" 'NR==2 {print $6}'`
        cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << END
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=static
IPADDR=192.168.4.$Suffix
PREFIX=24                                        #NETMASK=255.255.255.0
GATEWAY=192.168.4.1
DNS1=114.114.114.114
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth0"
END
        Msg "config eth0"
}

# Defined Yum Functions
function Yum() {
        yum -y install epel-release.noarch
        yum -y install make patch gzip unzip glibc util-linux tar telnet lrzsz vim ntpdate man gcc gcc-c++
        yum -y upgrade
        Msg "YUM source"
}

# Defined Hide the system version number Functions
function HideVersion() {
        [ -f "/etc/issue" ] && >/etc/issue
        Msg "Hide issue"
        [ -f "/etc/issue.net" ] && > /etc/issue.net
        Msg "Hide issue.net"
}

# Defined OPEN FILES And Processes Functions
function FilesProcesses() {
        [ -f "/etc/security/limits.conf" ] && {
        echo '*  soft  nproc   102400' >> /etc/security/limits.conf
        echo '*  hard  nproc   102400' >> /etc/security/limits.conf
        echo '*  soft  nofile  102400' >> /etc/security/limits.conf
        echo '*  hard  nofile  102400' >> /etc/security/limits.conf
        }
        Msg "Open files, Processes"
}

# Defined Kernel parameters Functions
function Kernel() {
        cat >> /etc/sysctl.conf << EOF

net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.ip_local_port_range = 4096 6500
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_max_syn_backlog = 4096
net.core.netdev_max_backlog =  10240
net.core.somaxconn = 2048
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_mem = 94500000 915000000 927000000
EOF
        Msg "Kernel config"
}

# Defined System Startup Services Functions
function Boot() {
        for oldboy in `chkconfig --list|grep "3:on"|awk '{print $1}'|grep -vE "crond|network|rsyslog|sshd|sysstat"`
        do
           chkconfig $oldboy off
        done
        Msg "BOOT config"
}

# Defined Time Synchronization Functions
function Time() {
        echo "#time sync by liukj at $(date +%F)" >>/var/spool/cron/root
        echo "13 5,9,14,19 * * * /usr/sbin/ntpdate asia.pool.ntp.org > /dev/null 2>&1 && /sbin/hwclock -w " >>  /var/spool/cron/root
        Msg "Time Synchronization"
}

# Defined SSH Config Functions
function Ssh() {
        sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config && \
        sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
        Msg "SSH Config"
}

# Defined Selinux Config Functions
function Selinux() {
        sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
        Msg "Selinux Config"
}

# Defined Users Delete Functions
function UsersDel() {
       for user in lp sync shutdown halt uucp operator games gopher
       do
            userdel $user  
       done
       Msg "Users Delete"
}

# Defined Main Functions
function Main() {
        ConfigIP
        Yum
        HideVersion
        FilesProcesses
        Kernel
        Boot
        Time
        Ssh
        Selinux
        UserDel
}
Main
