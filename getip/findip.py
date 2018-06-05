#!/usr/bin/python

import os, sys
from polling import poll
import opendhcpd

'''
Input: domain name
Output: domain id
'''
def getDomId(name):
    cmd = 'sudo xl list | grep ' + name
    res = os.popen(cmd).read()
    if not res:
        return None
    id = res.split()[1].strip()
    return id

'''
Input: domain id
Output: mac address
'''
def getDomMac(id):
    cmd = 'sudo xenstore-read /local/domain/{0}/device/vif/0/mac'.format(id)
    mac = os.popen(cmd).read().strip()
    if not mac:
        return None
    return mac

'''
Input: domain mac address
Output: domain ip address
'''
def getDomIp(mac):
    leases = opendhcpd.parse_leases_file()
    return opendhcpd.getIPForMac(leases, mac)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        domainName = sys.argv[1]

        try:
            domainId = poll(lambda: getDomId(domainName), timeout=2, step=0.5)
        except:
            sys.exit('Error: Domain with name {0} not found'.format(domainName))

        try:
            domainMac = poll(lambda: getDomMac(domainId), timeout=2, step=0.5)
        except:
            sys.exit('Error: Domain Mac address for domain id {0} not found'.format(domainId))

        try:
            domainIP = poll(lambda: getDomIp(domainMac), timeout=30, step=0.5)
        except:
            sys.exit('Error: Domain IP address not found')

        print domainIP
    else:
        print "Error: Specify domain name as command line argument"