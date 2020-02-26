#!/bin/sh

# Version:202002261359


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

:>/var/log/write_disk.log

while true
do
	fDisplayMessage Info "#####begin:$(date)#####">>/var/log/write_disk.log
	rm ${lvGetMountPoint}/temp_sys -rf && \
	fDisplayMessage Right "delete is OK">>/var/log/write_disk.log
	mkdir -p ${lvGetMountPoint}/temp_sys && \
	lvGetMaxFreeDisk="$(df|grep -n ""|grep -v "^1:"|awk '{print $4}'|sort -nr|head -n 1)"
	lvGetMountPoint=$(df|grep -v "grep"|grep "${lvGetMaxFreeDisk}"|awk '{print $6}')
	lvGetRandomNmuber=${RANDOM}
	
	fDisplayMessage Info "MaxFreeDisk:${lvGetMaxFreeDisk}KB">>/var/log/write_disk.log
	fDisplayMessage Info "MountPoint:${lvGetMountPoint}">>/var/log/write_disk.log
	fDisplayMessage Info "RandomNumber:${lvGetRandomNmuber}">>/var/log/write_disk.log
	fDisplayMessage Info "Duration:$[${lvGetRandomNmuber}/60]minutes">>/var/log/write_disk.log
	
	#for ((i=0;i<5;i++));
	for ((i=0;i<${lvGetRandomNmuber};i++));
	do	
		lvGetFillUnit=$[${lvGetMaxFreeDisk}/10*6/${lvGetRandomNmuber}]
		fDisplayMessage Error ${lvGetFillUnit}>>/var/log/write_disk.log
		sleep 1
		dd if=/dev/zero of=${lvGetMountPoint}/temp_sys/${RANDOM}.tmp bs=1K count=${lvGetFillUnit} 2>/dev/null
	done
	
	fDisplayMessage Info "#####end:$(date)#####">>/var/log/write_disk.log
	echo "">>/var/log/write_disk.log
done
#file end