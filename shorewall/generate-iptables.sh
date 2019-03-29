# Remove Old Files
rm -f iptables_local.conf
rm -f iptables.conf

# Generate iptables.conf based on new configuration
sudo shorewall restart && sudo iptables-save > iptables_local.conf && sudo shorewall clear
cp iptables_local.conf iptables.conf
sed -i 's/enp0s25/eth0/g' iptables.conf
