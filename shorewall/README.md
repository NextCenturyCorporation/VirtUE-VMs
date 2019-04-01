# virtue-shorewall

Author: Hassan Nadeem (Virginia Tech)

## Installation
`apt-get install shorewall`
or
`yum install shorewall`

`mkdir -p /etc/shorewall`

`rm -rf /etc/shorewall/*`

`cp -r this_shorewall_directory/* /etc/shorewall/`

`cd /etc/shorewall`

### If running shorewall on target
`./restart_firewall.sh`

### Else
`sudo ./generate-iptables.sh`

`sudo iptables-restore < iptables.conf`

## Configuration
Modify "System Dependant Variables" in `/etc/shorewall/params` file
