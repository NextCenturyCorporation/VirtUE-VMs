#!/usr/bin/python
#
# Copyright (C) 2018-2019 Virginia Tech
# 
# This file may be redistributed and/or modified under either the GPL
# 2.0 or 3-Clause BSD license. In addition, the U.S. Government is
# granted government purpose rights. For details, see the COPYRIGHT.TXT
# file at the root of this project.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.
# 
# SPDX-License-Identifier: (GPL-2.0-only OR BSD-3-Clause)
#

from lxml import html
import urllib
import datetime, bisect


# Default location of leases file
LEASE_URL = 'http://192.168.0.3:6789'

def timestamp_now():
        n = datetime.datetime.utcnow()
        return datetime.datetime(n.year, n.month, n.day, n.hour, n.minute,
                n.second + (0 if n.microsecond < 500000 else 1))

def getIPForMac(lease_db, mac):
    return lease_db[mac]['ip_address'] if mac in lease_db else None

def parse_leases_file():
    lease_db = {}

    # open and parse html
    response = urllib.urlopen(LEASE_URL)
    data = response.read()
    tree = html.fromstring(data)

    # get the second table, that contains the lease information
    tbl = tree.xpath("/html//table[2]")[0]

    # get rows from 2nd onwards
    rows = [tr for tr in tbl.xpath('./tr')][2:]

    for row in rows:
        cells = [cell.text_content().strip() for cell in row.xpath('./td')]

        # create a lease record
        lease_rec = {}
        lease_rec['hardware'] = cells[0]
        lease_rec['ip_address'] = cells[1]
        lease_rec['ends'] = datetime.datetime.strptime(cells[2],'%d-%b-%y %H:%M:%S')
        lease_rec['client-hostname'] = cells[3]

        # add the record to lease database
        if lease_rec['ends'] >= timestamp_now():
            lease_db[lease_rec['hardware']] = lease_rec
    
    return lease_db

if __name__ == "__main__":
        leases = parse_leases_file()
        now = timestamp_now()
        report_dataset = [leases[key] for key in leases]

        print('+------------------------------------------------------------------------------')
        print('| DHCPD ACTIVE LEASES REPORT')
        print('+-----------------+-------------------+----------------------+-----------------')
        print('| IP Address      | MAC Address       | Expires (days,H:M:S) | Client Hostname ')
        print('+-----------------+-------------------+----------------------+-----------------')

        for lease in report_dataset:
            print('| ' + format(lease['ip_address'], '<15') + ' | ' + \
                    format(lease['hardware'], '<17') + ' | ' + \
                    format(str((lease['ends'] - now) if lease['ends'] != 'never' else 'never'), '>20') + ' | ' + \
                    lease['client-hostname']
                )

        print('+-----------------+-------------------+----------------------+-----------------')
        print('| Total Active Leases: ' + str(len(report_dataset)))
        print('| Report generated (UTC): ' + str(now))
        print('+------------------------------------------------------------------------------')