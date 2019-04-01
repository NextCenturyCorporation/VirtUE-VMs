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
# Remove Old Files
rm -f iptables_local.conf
rm -f iptables.conf

# Generate iptables.conf based on new configuration
sudo shorewall restart && sudo iptables-save > iptables_local.conf && sudo shorewall clear
cp iptables_local.conf iptables.conf
sed -i 's/enp0s25/eth0/g' iptables.conf
