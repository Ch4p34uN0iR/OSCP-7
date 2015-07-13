#!/bin/bash

ipv4=$(ifconfig |grep "inet"|cut -d" " -f 2|grep "\."|grep -v "127.0.0.1"|rev|cut -d"."  -f2-|rev)

for ip in $(seq 1 254); do
ping -c 1 $ipv4.$ip|grep "bytes from"|cut -d" " -f 4|cut -d":" -f1 &
done
