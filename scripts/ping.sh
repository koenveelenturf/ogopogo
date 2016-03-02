#!/bin/bash
#Author: Koen Veelenturf

#Ping script for UvA OS3 Ogopogo labs (INR)

usage()
{
cat << EOF
usage: $0 options

This script pings all the LAN segments in the Ogopogo topology.

OPTIONS:
	-r	The amount of routers in the topology
	-v	Verbose (Get detailed PING, set "-v")

	IPv4 values:
	-a 	The A value from the lab (for the IPv4 network)
	-b 	The B value from the lab (for the IPv4 network)

	IPv6 values:
	-x 	The X value from the lab (for the IPv6 network)
	-y 	The Y value from the lab (for the IPv6 network)

If you do not have IPv4 or IPv6, you can leave out the -a/-b or -x/-y values.
EOF
}

# default verbose
verbose=0

while getopts ":a:b:x:y:r:v" opt; do
	case $opt in
		a)
			a=$OPTARG
			if [ -z "$a" ]; then
				usage
				echo "Missing argument(s)!"
				exit 1
			fi
			;;
		b)
			b=$OPTARG
			if [ -z "$b" ]; then
				usage
				echo "Missing argument(s)!"
				exit 1
			fi
			;;
		x)
			x=$OPTARG
			if [ -z "$x" ]; then
				usage
				echo "Missing argument(s)!"
				exit 1
			fi
			;;
		y)
			y=$OPTARG
			if [ -z "$y" ]; then
				usage
				echo "Missing argument(s)!"
				exit 1
			fi
			;;
		r)
			routers=$OPTARG
			if [ -z "$routers" ]; then
				usage
				echo "Missing argument(s)!"
				exit 1
			fi
			;;
		v)
			verbose=1
			;;
		\?)
			usage
			echo "Invalid options: -$OPTARG"
			exit 1
			;;
		:)
			usage
			echo "Option -$OPTARG requires an argument!"
			exit 1
			;;			
	esac
done

shift $((OPTIND-1))

if [ -z $routers ]  ; then
	usage
	exit 1
else
	# Number of retries
	#retry=2 <-- this variable is set further down the script
	retry6=2

	if [[ $y -eq 0 ]] ; then
	    prefix="2001:db8:${x}00"
	else
		prefix="2001:db8:${x}00:${y}"
	fi

	# Initialise result(6) variables
	result=0
	result6=0

	echo "================================"
	echo "Amount of routers: ${routers}"
	if [ ! -z $a ] && [ ! -z $b ] ; then
		echo "Value A: ${a}"
		echo "Value B: ${b}"
		echo "IPv4 network: ${a}.${b}.x.x"
	fi
	if [ ! -z $x ] && [ ! -z $y ] ; then
		echo "Value X: ${x}"
		echo "Value Y: ${y}"
		echo "IPv6 prefix: ${prefix}::"
	fi
	
	echo ""
	echo "When ping fails, I'll try: 2x"
	echo "================================"

	if [[ ! -z $a ]] || [[ ! -z $b ]] ; then
		# IPv4 ping
		for (( i=1; i<=$routers; i++ ))
		do
			retry=2
			while [[ ${retry} -ne 0 ]] ; do
				echo ""
				echo "Pinging ${a}.${b}.$i.$i ..."
				if [ $verbose -eq 1 ] ; then
					ping -c 2 $a.$b.$i.$i
				else
					ping -c 2 $a.$b.$i.$i > /dev/null
				fi
				rc=$?
				if [[ $rc -eq 0 ]] ; then
					echo "L$i is reachable over IPv4!"
					retry=0
					result=$[$result+1]
				else
					echo "L$i is NOT reachable over IPv4!"
					retry=$[$retry-1]
					echo "I will try another $retry time(s)!"
				fi
			done
		done

		echo -e "\nYou can reach ${result} of the ${routers} routers over IPv4..."
	fi

	if [[ ! -z $x ]] || [[ ! -z $y ]] ; then
		# IPv6 ping
		if [[ $y -eq 0 ]] ; then
			for (( j=1; j<=$routers; j++ ))
			do
				retry6=2
				while [[ ${retry6} -ne 0 ]] ; do
					echo ""
					echo "Pinging ${prefix}:${j}::${j} ..."
					if [ $verbose -eq 1 ] ; then
				        	ping6 -c 2 ${prefix}:${j}::${j}
					else
						ping6 -c 2 ${prefix}:${j}::${j} > /dev/null
					fi 
				        rc=$?
				        if [[ $rc -eq 0 ]] ; then
				            echo "L$j is reachable over IPv6!"
				            retry6=0
					    result6=$[$result6+1]
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
					if [ $verbose -eq 1 ] ; then
			        		ping6 -c 2 ${prefix}${j}::$(echo $j | sed 's/^0*//')
			        	else
						ping6 -c 2 ${prefix}${j}::$(echo $j | sed 's/^0*//') > /dev/null
					fi
					rc=$?
			        	if [[ $rc -eq 0 ]] ; then
			        	echo "L$j is reachable over IPv6!"
			            	retry6=0
					result6=$[$result6+1]
			        else
					echo "L$j is NOT reachable over IPv6!"
			       		retry6=$[retry6-1]
			       		echo "I will try another $retry6 time(s)!"
			       	fi
			   	done
			done
		fi

		echo -e "\nYou can reach ${result6} of the ${routers} routers over IPv6..."
	fi
fi
