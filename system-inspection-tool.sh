#!/bin/bash

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

fCheckCpuInfo(){
	#us — user： 运行(未调整优先级的) 用户进程的CPU时间
	#sy — system: 运行内核进程的CPU时间
	#ni — niced：运行已调整优先级的用户进程的CPU时间
	#id — idle：CPU空闲时间
	#wa — IO wait: 用于等待IO完成的CPU时间
	#hi — 处理硬件中断的CPU时间
	#si — 处理软件中断的CPU时间
	#st — 这个虚拟机被hypervisor偷去的CPU时间（译注：如果当前处于一个hypervisor下的vm，实际上hypervisor也是要消耗一部分CPU处理时间的）。
	#us — 用户空间占用CPU的百分比。
	#sy — 内核空间占用CPU的百分比。
	#ni — 改变过优先级的进程占用CPU的百分比
	#id — 空闲CPU百分比
	#wa — IO等待占用CPU的百分比
	#hi — 硬中断（Hardware IRQ）占用CPU的百分比
	#si — 软中断（Software Interrupts）占用CPU的百分比

	top -n 1 -d 1|grep "^%Cpu"
	top -n 1 -d 1|grep "^%Cpu"|awk '{OFS=",";print $2,$4,$6,$8,$10,$12,$14,$16}' >> temp.csv
	}
#fCheckCpuInfo

fChcekMemInfo(){
	#total — 物理内存总量
	#used — 使用中的内存总量
	#free — 空闲内存总量
	#buffers — 缓存的内存量
	
	top -n 1 -d 1|grep "buff/cache"
	top -n 1 -d 1|grep "buff/cache"|awk '{OFS=",";print $4,$6,$8,$10}' >> temp.csv
	}
#fChcekMemInfo

fCheckDiskInfo(){
	df|grep "^/dev"
	local lvPartitionNumber="$(df|grep "^/dev"|wc -l)"
	#echo ${lvPartitionNumber}
	for ((i=1;i<=${lvPartitionNumber};i++));
	do
		echo "$(df | grep "^/dev" | sed -n ${i}p | awk '{OFS=",";print $1,$2,$3,$4,$5,$6}')" >> temp.csv
	done
	}
#fCheckDiskInfo

echo -e "hostip:,$(hostname -I|awk '{print $1}')\n" > temp.csv
echo -e "hostname:,$(hostname)\n" >> temp.csv
echo -e "CPUINFO\nus,sy,ni,id,wa,hi,si,st" >> temp.csv
echo "CPUINFO"
fCheckCpuInfo
echo -e "MEMINFO\ntotal(KB),used(KB),free(KB),buff(KB)/cache(KB)" >> temp.csv
echo "MEMINFO"
fChcekMemInfo
echo -e "DISKINFO\ndevice,total(KB),used(KB),free(KB),used%,mountpoint" >> temp.csv
echo "DISKINFO"
fCheckDiskInfo

mv temp.csv Report-$(hostname -I|awk '{print $1}')-$(date +%Y%m%d%H%M%S).csv

#file end
