#!/bin/bash

function calc()
{
	tmp=$(awk "BEGIN{print $*}" | grep -oE "[0-9]{1,3}\.[0-9]{0,2}")
	echo $tmp
}

arch=$(uname -a)
proc_p=$(grep "processor" /proc/cpuinfo | wc -l)
proc_v="$(grep "processor" /proc/cpuinfo | wc -l)"

mem_total=$(sed -nE 's|MemTotal:\s*([0-9]+).*|\1|p' /proc/meminfo)
mem_free=$(sed -nE 's|MemAvailable:\s*([0-9]+).*|\1|p' /proc/meminfo)
mem_used=$((${mem_total} - ${mem_free}))
mem_used=$((${mem_used} / 1024))
mem_total=$((${mem_total} / 1024))
mem_pourcentage=$(calc "${mem_used} * 100 / ${mem_total}")
mem="${mem_used}/${mem_total}MB (${mem_pourcentage}%)"

current_disk=$(lsblk | sed -nE 's|.*(sd[a-z][0-9]).*/$|\1|p')
disk_used=$(df --total -h --output=source,used | sed -nE 's|total\s*(.*)[GTM]|\1|p')
disk_total=$(df --total -h --output=source,size | sed -nE 's|total\s*(.*)[GTM]|\1|p')
disk_suffix=$(df --total -h --output=source,size | sed -nE 's|total\s*.*([GTM])|\1|p')

disk_pourcentage=$(calc "${disk_used} * 100 / ${disk_total}")
disk="${disk_used}/${disk_total}${disk_suffix} (${disk_pourcentage}%)"

cpu_free=$(cat /proc/stat | grep 'cpu[0-9]' | awk '{print ($5*100)/($2+$3+$4+$5+$6+$7+$8+$9+$10)}')
cpu_free=$(calc "100-${cpu_free}")
cpu="${cpu_free}%"

last_boot=$(who -b | sed -nE 's|.*([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2})|\1|p')

[[ -z $(lsblk | grep 'lvm') ]] && have_lvm="no" || have_lvm="yes"
lvm=${have_lvm}

tcp=$(ss | grep -E 'tcp\s*ESTAB' | wc -l)

logged=$(who | cut -d" " -f 1 | sort -u | wc -l)

net_ip=$(ip a s | sed -nE 's|inet ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\/[0-9]{1,2} brd.*|\1|p')
net_mac=$(ip a s | sed -nE 's|link/ether ([a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}).*|\1|p')
net="IP ${net_ip} (${net_mac// /})"

sudo_count=$(grep --binary-files=text -w 'COMMAND' /var/log/sudo/sudo.log | grep -v "USER=root" | wc -l)

tabs 20
wall		'#Architecture:'$'\t'${arch}	\
	   $'\n''#CPU physical:'$'\t'${proc_p}	\
	   $'\n''#vCPU:'$'\t'${proc_v}		\
	   $'\n''#Memory usage:'$'\t'${mem}		\
	   $'\n''#Disk Usage:'$'\t'${disk}		\
	   $'\n''#CPU Load:'$'\t'${cpu}			\
	   $'\n''#Last boot:'$'\t'${last_boot}	\
	   $'\n''#LVM use:'$'\t'${lvm}		\
	   $'\n''#Connection TCP:'$'\t'${tcp}	\
	   $'\n''#User log:'$'\t'${logged}		\
	   $'\n''#Network:'$'\t'${net}		\
	   $'\n''#Sudo:'$'\t'${sudo_count}

# echo		'#Architecture: '${arch}		\
#	   $'\n''#CPU physical: '${proc_p}	\
#	   $'\n''#vCPU: '${proc_v}		\
#	   $'\n''#emory usage: '${mem}		\
#	   $'\n''#Disk Usage: '${disk}		\
#	   $'\n''#CPU Load: '${cpu}		\
#	   $'\n''#Last boot: '${last_boot}	\
#	   $'\n''#LV use: '${lvm}		\
#	   $'\n''#Connection TCP: '${tcp}		\
#	   $'\n''#User log: '${logged}		\
#	   $'\n''#Network: '${net}		\
#	   $'\n''#Sudo: '${sudo} # > output_base
