#! /bin/sh

SCRIPTDIR=$(dirname $0)

export https_proxy=127.0.0.1:7890

wget -O $SCRIPTDIR/geoip.dat \
	https://github.com/v2fly/geoip/releases/latest/download/geoip.dat

wget -O $SCRIPTDIR/geosite.dat \
	https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat

sudo mv $SCRIPTDIR/geoip.dat /usr/share/v2ray/
sudo mv $SCRIPTDIR/geosite.dat /usr/share/v2ray/
