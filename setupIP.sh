#!/bin/sh
#
# Filename: setupIP.sh
# Features: set ipaddress
# Version: 0.1
# Buildtime: 2019-09-07-17-06
# Auteur: guile.liao
# Email: liaolei@geostar.com.cn
# Copyleft: Licensed under the GPLv3
#
#=========
# 错误代码
#=========
# 1=用户不同意免责声明
# 2=用户不是root
# 3=输入网卡名称有误
# 4=输入IP地址有误
#=============
# 脚本容错配置
#=============
# e让脚本执行中遇到错误自动退出
# u忽略不存在的变量
# x执行前输出命令体
# o pipefail只要一个子命令失败，整个管道命令就失败，脚本就会终止执行
#set -eux
#set -o pipefail
#
#===================
# 定义脚本内全局变量
#===================
# 获取网络接口信息
local laGetNicList=($(ip addr show|egrep "^[1-9]"|grep -v 'lo:'|awk -F ':' '{print $2}'|sed s/' '/''/))
# 获取NIC名称
local lvNicName="null"
# 定义IP地址存放变量
local lvIpaddr="null"
#
#===============
# 自定义功能模块
#===============
# 定义交互式消息函数
fDisplayMessage(){
	case $1 in
		Error)
			shift
			printf "\033[31;1m%s\033[0m\n" "$@"
			;;
		Right)
			shift
			printf "\033[32;1m%s\033[0m\n" "$@"
			;;
		Info)
			shift
			printf "\033[33;1m%s\033[0m\n" "$@"
			;;
		Help|*)
			shift
			printf "     \033[1m%-15s\033[0m%s\n" "$@"
			;;
	esac
}
#fDisplayMessage
#
#同意免责声明，否则不允许使用该脚本
fdisclaimer(){
	fDisplayMessage Error "This tool is developed by GeoStar. GeoStar will not assume any responsibility for any loss caused by the use of this tool. If you agree to this, please enter 'yes' and proceed to the next step."
	read -p "Please input:" lvUserChange
	if [ "${lvUserChange}" != "yes" ];then
		echo "${lvUserChange}bye-bye!" && exit 1
	fi
}
#fdisclaimer
#
# 定义环境判断函数
fCheckUser(){
	if [ -z "$(whoami|grep "root")" ];then
		fDisplayMessage Error "Please login with 'root' account." && exit 2
	fi
}
#fCheckUser
#
# 从标准输入获取网卡名称
fGetNicName(){
	read -p "Please give me NIC name: " lvNicName
	if [ -n "$(echo ${laGetNicList[@]}|grep "${lvNicName}")" ];then
			echo "Your NIC is: ${lvNicName}"
		else
			fDisplayMessage Error "NIC name is wrong." && exit 3
		fi
}
#fGetNicName
#
# 从标准输入获取IP地址
fGetIpaddr(){
	if [ -z "$(hostname -I)" ];then
		read -p "Please give me ipaddress: " lvIpaddr
	else
		fDisplayMessage Error "I already have an ipaddress. Press 'Enter' to make sure you know what you're doing." && \
		read && \
		read -p "Please give me an ipaddress: " lvIpaddr
	fi
	if [[ "${lvIpaddr}" =~ ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-3])$ ]];then
		echo "Your input is: "${lvIpaddr}""
	else
		fDisplayMessage Error "Ipaddress is wrong." && exit 4
	fi
}
#fGetIpaddr
#
# 生成网关
fBuileGateway(){
	echo "${lvIpaddr%.*}.254"
}
#fBuileGateway
#
#
#
# 写入网络接口配置信息
fWriteIfcfg(){
	cp -a /etc/sysconfig/network-scripts/ifcfg-${lvNicName} /etc/sysconfig/network-scripts/ifcfg-${lvNicName}.$(date +%Y%m%d%H%M%S)
	cat>/etc/sysconfig/network-scripts/ifcfg-${lvNicName}<<EOF
TYPE="Ethernet"
DEVICE="${lvNicName}"
ONBOOT="yes"
BOOTPROTO="none"
NM_CONTROLLED="no"
PEERDNS="no"
IPADDR="${lvIpaddr}"
PREFIX="24"
GATEWAY="$(fBuileGateway)"
DNS1="172.16.44.12"
EOF
}
#fCreateIfcfg
#
#
#
#
#
#=========
# 流程实现
#=========
#
clear
fDisplayMessage Info "========================================="
fDisplayMessage Info "                 Setup IP                "
fDisplayMessage Info "========================================="
fDisplayMessage Info "Hostname: $(hostname)"
fDisplayMessage Info "NIC: ${laGetNicList[*]}"
fGetNicName
fGetIpaddr
fWriteIfcfg
ifdown ${lvNicName} && \
ifup ${lvNicName} && \
ping -w 3 $(fGetIpaddr)
#
# file end