#!/bin/sh

trikrc=/home/root/.trikrc
interface=wlan0

if [ ! -f $trikrc ]
	then
		touch $trikrc
fi

source $trikrc

if [ x$trik_wifi_mode = x ]
	then
		sed --in-place '/^trik_wifi_mode=/d' $trikrc
		trik_wifi_mode=client
		echo "trik_wifi_mode=$trik_wifi_mode" >>$trikrc
fi

if [ $trik_wifi_mode = ap ]
	then
		sh /home/root/set_wifi_mode.sh ap
fi

