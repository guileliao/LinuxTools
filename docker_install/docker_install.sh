#!/bin/sh


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
			printf "     \033[1m%s\033[0m%s\n" "$@"
			;;
	esac
}
#fDisplayMessage

fCheckOSversion(){
	if [ -z "$(cat /etc/centos-release|grep "CentOS"|grep "7")" ];then
		fDisplayMessage Error "OS not CentOS7.x" && exit 1
	fi
}
#fCheckOSversion

fCheckSElinux(){
	if [ -z "$(grep "^SELINUX=permissive" /etc/selinux/config)" ];then
		fDisplayMessage Error "SElinux status not permissive" && exit 2
	fi
}
#fCheckSElinux

fCheckDockerInstall(){
	if [ -n "$(rpm -qa|grep "docker*")" ];then
		yum remove -y docker*
	fi
	if [ -n "$(ps aux|grep "dockerd"|grep -v "grep")" ];then
		kill -9 $(ps aux|grep "docker"|grep -v "grep"|awk '{print $2}')
	fi
}
#fCheckDockerInstall

fAutoRunDockerd(){
	if [ -z "$(grep "^dockerd.*\&" /etc/rc.d/rc.local)" ];then
		echo 'dockerd --insecure-registry "registry.gfstack.geo:5555" --bip "192.168.222.1/24" --data-root "/var/lib/docker" -H "0.0.0.0:2375" -H "unix:///var/run/docker.sock" --userland-proxy=false &' >> /etc/rc.d/rc.local
		chmod +x /etc/rc.d/rc.local
	fi
}
#fAutoRunDockerd

gvRootPath="$(dirname ${0})"
gvScriptName="$(basename ${0})"

case ${1} in
	--install)
		#fCheckOSversion;
		fCheckSElinux;
		fCheckDockerInstall;
		find ${gvRootPath} -maxdepth 1 -type f|grep -v "${gvScriptName}"|xargs -I {} rm /usr/bin/{} -rf && \
		find ${gvRootPath} -maxdepth 1 -type f|grep -v "${gvScriptName}"|xargs -I {} cp -a {} /usr/bin && \
		fAutoRunDockerd
		;;
	--uninstall)
		find ${gvRootPath} -maxdepth 1 -type f|grep -v "${gvScriptName}"|xargs -I {} rm /usr/bin/{} -rf
		;;
	--help|*)
		fDisplayMessage Help "MAINTAINER 		"guile.liao" "liaolei@geostar.com.cn""
		fDisplayMessage Help "USAGE			setup.sh [--install|--uninstall|--help]" 
		fDisplayMessage Help "--install			copy docker-engin to /usr/bin and setup autorun."
		fDisplayMessage Help "--uninstall		delete docker-engin."
		;;
esac
