#!/bin/sh
sudo brctl addbr xenbr0
sudo ifconfig xenbr0 192.168.0.1 netmask 255.255.255.0 up
echo '1' | sudo tee --append /proc/sys/net/ipv4/ip_forward
sudo iptables-restore < /home/ec2-user/iptables.conf
