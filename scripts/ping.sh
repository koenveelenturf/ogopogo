#!/bin/bash
# Author: Koen Veelenturf

# Number of retries
#retry=2
retry6=2

# A (A.B.x.x)
a=4

# B (A.B.x.x)
b=10

# x (2001:0db8:0x00:0y00::1/58)
x="d"

# y
y=0

if [[ $y -eq 0 ]] ; then
    prefix="2001:db8:${x}00"
else
	prefix="2001:db8:${x}00:${y}"
fi

# amount of routers, max = 99
routers=6

echo "================================"
echo "Amount of routers: ${routers}"
echo "Value A: ${a}"
echo "Value B: ${b}"
echo "Value X: ${x}"
echo "Value Y: ${y}"
echo ""
echo "IPv4 network: ${a}.${b}.x.x"
echo "IPv6 prefix: ${prefix}:"
echo ""
echo "When ping fails, I'll try: 2x"
echo "================================"

for (( i=1; i<=$routers; i++ ))
do
	retry=2
	while [[ ${retry} -ne 0 ]] ; do
		echo ""
		echo "Pinging ${a}.${b}.$i.$i ..."
		ping -c 2 $a.$b.$i.$i > /dev/null
		rc=$?
		if [[ $rc -eq 0 ]] ; then
			echo "L$i is reachable over IPv4!"
			retry=0
		else
			echo "L$i is NOT reachable over IPv4!"
			retry=$[$retry-1]
			echo "I will try another $retry time(s)!"
		fi
	done
done
if [[ $y -eq 0 ]] ; then
	for (( j=1; j<=$routers; j++ ))
	do
		retry6=2
		while [[ ${retry6} -ne 0 ]] ; do
			echo ""
			echo "Pinging ${prefix}:${j}::${j} ..."
	        ping6 -c 2 ${prefix}${j}::${j} > /dev/null
	        rc=$?
	        if [[ $rc -eq 0 ]] ; then
	            echo "L$j is reachable over IPv6!"
	            retry6=0
	        else
	            echo "L$j is NOT reachable over IPv6!"
	       		retry6=$[retry6-1]
	       		echo "I will try another $retry6 time(s)!"
	       	fi
	   	done
	done
else
	for j in $(seq -f %02g 1 ${routers})
	do
		retry6=2
		while [[ ${retry6} -ne 0 ]] ; do
			echo ""
			echo "Pinging ${prefix}${j}::$(echo $j | sed 's/^0*//') ..."
	        ping6 -c 2 ${prefix}${j}::$(echo $j | sed 's/^0*//') > /dev/null
	        rc=$?
	        if [[ $rc -eq 0 ]] ; then
	            echo "L$j is reachable over IPv6!"
	            retry6=0
	        else
	            echo "L$j is NOT reachable over IPv6!"
	       		retry6=$[retry6-1]
	       		echo "I will try another $retry6 time(s)!"
	       	fi
	   	done
	done
fi
