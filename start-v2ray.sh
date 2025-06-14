#! /bin/sh

set -e
SCRIPTDIR=$(dirname $0)

if test $# -lt 1; then
	echo "The config file ID is not specified" >&2
	exit 1
fi

if ! echo $1 | grep -q '[0-9][0-9][0-9]'; then
	echo "Invalid ID: $1" >&2
	exit 2
fi

server=$(cat $SCRIPTDIR/db-v2ray/$1*/server)
tag=$(cat $SCRIPTDIR/db-v2ray/$1*/tag)

#echo "server config:" $server
echo "server tag:" $tag

sed "s|<SERVER>|$server|" $SCRIPTDIR/config-v2ray.json.tmpl \
	> $SCRIPTDIR/config-v2ray.json

v2ray -config $SCRIPTDIR/config-v2ray.json

