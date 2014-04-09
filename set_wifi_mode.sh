#!/bin/sh

# Copyright 2014 CyberTech Labs Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

trikrc=/etc/trik/trikrc
interface=wlan0
hostapd_conf=/etc/hostapd.conf

generate_ap_ssid() {
	sed --in-place '/^trik_wifi_ap_ssid=/d' $trikrc
	trik_wifi_ap_ssid="trik-`cat /sys/class/net/$interface/address | tail -c 9`"
	echo "trik_wifi_ap_ssid=$trik_wifi_ap_ssid" >>$trikrc
}

generate_ap_passphrase() {
	sed --in-place '/^trik_wifi_ap_passphrase=/d' $trikrc
	trik_wifi_ap_passphrase=""
	for i in 1 2 3 4 5 6 7 8
		do
			random=`hexdump -n1 -e\"%u\"  /dev/urandom`
			let "digit = $random % 10"
			trik_wifi_ap_passphrase=$trik_wifi_ap_passphrase$digit
		done
	echo "trik_wifi_ap_passphrase=$trik_wifi_ap_passphrase" >>$trikrc
}

generate_hostapd_conf() {
		echo "interface=$interface
driver=nl80211
ssid=$trik_wifi_ap_ssid
hw_mode=g
channel=1
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$trik_wifi_ap_passphrase
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP" >$hostapd_conf
}

if [ ! $1 = "client" ] && [ ! $1 = "ap" ]
	then
		echo "Usage: set_wifi_mode.sh client|ap"
		exit 1
fi

killall -q hostapd udhcpd
ifdown $interface

if [ ! -f $trikrc ]
	then
		touch $trikrc
fi

sed --in-place '/^trik_wifi_mode=/d' $trikrc
echo "trik_wifi_mode=$1" >>$trikrc

case "$1" in
	"client")
		ifup $interface
		;;
	
	"ap")
		source $trikrc

		if [ x$trik_wifi_ap_ssid = x ]
			then
				generate_ap_ssid
		fi

		if [ x$trik_wifi_ap_passphrase = x ]
			then
				generate_ap_passphrase
		fi

		generate_hostapd_conf

		hostapd -B $hostapd_conf
		ifconfig $interface 192.168.1.1 netmask 255.255.255.0
		udhcpd
		;;
esac

