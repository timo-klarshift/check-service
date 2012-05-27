#!/bin/bash

# Author:	Timo Friedl (timo@klarshift.de)
# Date:		26th May, 2012
#

# colors 
cEscape="\033"
cGreen="${cEscape}[32m"
cRed="${cEscape}[31m"
cYellow="${cEscape}[33m"
cHeader="${cEscape}[1;34m"
cReset="${cEscape}[0m"

# state
down=0
total=0

# clean up
init(){
	# delete outfiles
	rm "up-services.txt" > /dev/null 2>/dev/null
	rm "down-services.txt" > /dev/null 2>/dev/null
}

summary(){
	echo ""
	
	if [ $down -eq 0 ]; then
		echo -e "${cGreen}Everything OK :: 100% UP"
	else
		echo -e "${cRed}WARNING - Not all Services online\n${cReset}[DOWN/TOTAL] Ratio ::  ${cRed}$down/$total"
	fi
	echo -e "${cReset}"
	
}

# tab helper
printTabs(){
	for (( c=1; c<$1; c++ ))
	do echo -en " "; done
}

# check server method
checkServer(){
	# check params
	if [ $# -lt 2 ]; then return; fi;
	ip=$1; port=$2	
	echo -ne "${cReset}$ip"
	
	total=$((total+1))
	
	# indent
	len=`expr length $ip`
	tabs=$((25 - len))
	printTabs tabs
	
	echo -ne "$port\t"
	
	if [ "$(nmap -P0 -p$port $ip | grep open)" ]
	then
		echo -e "${cGreen}UP"		
		echo "$ip:$port" >> "up-services.txt"
	else
		echo -e "${cRed}DOWN"		
		echo "$ip:$port" >> "down-services.txt"
		down=$((down+1))
	fi		
	echo -ne "${cReset}"	# reset color
}

# check services from file
checkFile(){	
	
	while read line
	do 
		if [ "${line:0:1}" != "#" ]; then
			host=`echo "$line" | cut -d':' -f1`
			port=`echo "$line" | cut -d':' -f2`					
			checkServer $host $port
		fi
	done < $1
	summary
}

# nice header
printCheckHeader(){
	echo -e "${cHeader}HOST\t\t\tPORT\tSTATUS"	
}

# show usage
showUsage(){
	echo -e "USAGE";
	echo -e "\t./server-check.sh [IP] [PORT]"
		echo -e "\t\tEXAMPLE: ./server-check.sh 127.0.0.1 80"
	echo -e "\t./server-check [SERVICE-FILE]"
		echo -e "\t\tEXAMPLE 127.0.0.1:80"
}

## functions end ##

################## START ###############################################
clear
if [ $# -eq 1 -o $# -eq 2 ]
then
	echo -e "${cYellow}[CHECK SERVICES] // klarshift.de";
	echo -e "${cReset}"
	
	# read from file
	if [ $# -eq 1 -a -f $1 ]; then
		init		
		printCheckHeader
		checkFile $1		
		exit;
	# read single service
	elif [ $# -eq 2 ]; then
		init
		printCheckHeader
		checkServer $1 $2
		summary
		exit;		
	fi	
fi

# show usage as fallback
showUsage
exit;

################### END ################################################
