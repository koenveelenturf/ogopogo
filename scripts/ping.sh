#!/bin/bash
# Author: Koen Veelenturf

# Number of retries
retry=3

# A (A.B.x.x)
a=4

# B (A.B.x.x)
b=10

# x (2001:0db8:0x00:0y00::1/58)
x="d"

# y
y=0

if [[ $y -eq 0 ]] ; then
        prefix="2001:db8:${x}00:"
fi

# amount of routers
routers=6

while [[ $retry -ne 0 ]] ; do
        for (( i=1; i<=$routers; i++ ))
        do
                echo ""
                echo "Pinging ${a}.${b}.$i.$i..."
                ping -c 2 $a.$b.$i.$i > /dev/null
                rc=$?
                if [[ $rc -eq 0 ]] ; then
                        echo "L$i is reachable over IPv4!"
                        ((retry = 1))
                else
                        echo "L$i is NOT reachable over IPv4!"
                fi
                ((retry = retry - 1 ))
        done

        for (( j=1; j<=$routers; j++ ))
        do
                echo ""
                echo "Pinging ${prefix}${j}::${j}..."
                ping6 -c 2 ${prefix}${j}::${j} > /dev/null
                rc=$?
                if [[ $rc -eq 0 ]] ; then
                        echo "L$j is reachable over IPv6!"
                        ((retry = 1))
                else
                        echo "L$j is NOT reachable over IPv6!"
                fi
                ((retry = retry - 1))
        done
done
