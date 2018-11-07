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
                        printf "     \033[1m%-15s\033[0m%s\n" "$@"
                        ;;
        esac
}
#fDisplayMessage

fCalculatePi(){
	echo "scale="10000";4*a(1)"|./bin/bc -l>/dev/null
}
#fCalculatePi

fFillMemory(){
	umount tmpfs 2>/dev/null && rm tmpfs/* -rf 2>/dev/null
	mkdir -p tmpfs && mount -t tmpfs -o size=5M tmpfs tmpfs
	fFillDisk
	umount tmpfs 2>/dev/null && rm tmpfs/* -rf 2>/dev/null
}
#fFillMemory

fFillDisk(){
	rm tmpfs/tmpfile.1MB -rf 2>/dev/null
	for ((i=0;i<1048576;i++));
	do
		echo -e "1\c" >> tmpfs/tmpfile.1MB
	done
	rm tmpfs/tmpfile.1MB -rf 2>/dev/null
}
#fFillDisk

case $1 in
	--cpu)
		fDisplayMessage Info "#================================================="
		fDisplayMessage Right "CPU_Type=$(cat /proc/cpuinfo | grep "^model name"|awk -F ':' '{print $2}'|head -n 1|sed "s/.//")"
		fDisplayMessage Right "CPU_Core=$(cat /proc/cpuinfo | grep processor|wc -l)Core"
		fDisplayMessage Right "PI_Precision=10000Bits."
		fDisplayMessage Info "#================================================="
		fDisplayMessage Info "Begining..."
		time fCalculatePi
		fDisplayMessage Info "Finished..."
		;;
	--memory)
		fDisplayMessage Info "#================================================="
		fDisplayMessage Right "Fill_Area_Size=5MB." "Fill_File_Size=1MB."
		fDisplayMessage Info "#================================================="
		fDisplayMessage Info "Begining..."
		time fFillMemory
		fDisplayMessage Info "Finished..."
		;;
	--disk)
		fDisplayMessage Info "#================================================="
		fDisplayMessage Right "Fill_File_Size=1MB."
		fDisplayMessage Info "#================================================="
		fDisplayMessage Info "Begining..."
		time fFillDisk
		fDisplayMessage Info "Finished..."
		;;
	--help|-h|*)
		fDisplayMessage Help "Help info" "--cpu" "--memory" "--disk" "--help|-h"
		;;
esac
