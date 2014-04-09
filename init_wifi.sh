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

