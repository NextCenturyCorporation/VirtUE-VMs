#!/bin/sh
sudo brctl addbr xenbr0
sudo ifconfig xenbr0 10.0.0.1 netmask 255.255.255.0 up
echo '1' | sudo tee --append /proc/sys/net/ipv4/ip_forward
sudo iptables -A FORWARD --in-interface xenbr0 -j ACCEPT
sudo iptables --table nat -A POSTROUTING --out-interface wlp3s0 -j MASQUERADE
