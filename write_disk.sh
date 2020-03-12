#!/bin/sh

# Version:202003051725


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

fGetMaxFreeDisk(){
	df|grep -n ""|grep -v "^1:"|awk '{print $4}'|sort -nr|head -n 1
}
#fGetMaxFreeDisk

fGetMountPoint(){
	local lvGetMountPointHead="$(df|grep -v "grep"|grep "$(fGetMaxFreeDisk)"|awk '{print $6}')"
	if [ "${lvGetMountPointHead}" = "/" ];then
		echo "${lvGetMountPointHead}temp_sys"
	else
		echo "${lvGetMountPointHead}/temp_sys"
	fi
}
#fGetMountPoint

:>/var/log/write_disk.log


while true
do
	lvGetRandomNmuber=${RANDOM}
	fDisplayMessage Info "#####begin:$(date +%F_%T_%N)#####">>/var/log/write_disk.log
	fDisplayMessage Info "$(date +%F_%T_%N) MaxFreeDisk:$(fGetMaxFreeDisk)KB">>/var/log/write_disk.log
	fDisplayMessage Info "$(date +%F_%T_%N) MountPoint:$(fGetMountPoint)">>/var/log/write_disk.log
	fDisplayMessage Info "$(date +%F_%T_%N) RandomNumber:${lvGetRandomNmuber}">>/var/log/write_disk.log
	fDisplayMessage Info "$(date +%F_%T_%N) Duration:$[${lvGetRandomNmuber}/60]minutes">>/var/log/write_disk.log

	rm $(fGetMountPoint) -rf && \
	fDisplayMessage Right "$(date +%F_%T_%N) Directory deleted successfully">>/var/log/write_disk.log
	mkdir -p $(fGetMountPoint) && \
	fDisplayMessage Right "$(date +%F_%T_%N) Directory created successfully">>/var/log/write_disk.log
	lvGetFillUnit=$[$(fGetMaxFreeDisk)/10*6/${lvGetRandomNmuber}]
	fDisplayMessage Error "$(date +%F_%T_%N) ${lvGetFillUnit}">>/var/log/write_disk.log
		
	# for ((i=0;i<5;i++));
	for ((i=0;i<${lvGetRandomNmuber};i++));
	do	
		sleep 1
		dd if=/dev/zero of=${lvGetMountPoint}/temp_sys/${RANDOM}.tmp bs=1K count=${lvGetFillUnit} 2>/dev/null
	done
	
	rm $(fGetMountPoint) -rf && \
	fDisplayMessage Right "$(date +%F_%T_%N) Directory deleted successfully">>/var/log/write_disk.log
	fDisplayMessage Info "#####end:$(date +%F_%T_%N)#####">>/var/log/write_disk.log
	echo "">>/var/log/write_disk.log
done
#file end