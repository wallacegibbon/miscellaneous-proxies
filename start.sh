#! /bin/bash

SCRIPTDIR=$(dirname $0)

if test $# -lt 1; then
	echo "The config file ID is not specified" >&2
	exit 1
fi

server=$(cat $SCRIPTDIR/db/$1*/server)
tag=$(cat $SCRIPTDIR/db/$1*/tag)

echo
echo "server config:" $server
echo "server tag:" $tag

sed "s|<SERVER>|$server|" $SCRIPTDIR/config.json.tmpl \
	> $SCRIPTDIR/config.json

v2ray -config $SCRIPTDIR/config.json

