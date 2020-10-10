#!/bin/bash

echo "ipaddress,statu" > ip_statu_list.csv


fCheckFreeIp(){
	for ((i=1;i<=253;i++));
	do
		if [ "$(ping -w 2 172.16.20.${i}|grep received|awk '{print $4}')" = "0" ];then
			echo "172.16.20.${i},up" >> ip_statu_list.csv
		else
			echo "172.16.20.${i},down"  >> ip_statu_list.csv
		fi
	done
}
fCheckFreeIp
