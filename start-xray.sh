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

server=$(cat $SCRIPTDIR/db-xray/$1*/server | sed -z 's/\s\s*/ /g')
tag=$(cat $SCRIPTDIR/db-xray/$1*/tag)

#echo "server config:" $server
echo "server tag:" $tag

echo Custom direct domains: $DIRECTDOMAIN
echo Custom direct IPs: $DIRECTIP

if test -n "$DIRECTDOMAIN"; then
	DIRECTDOMAIN=",\"$(echo $DIRECTDOMAIN | sed 's/,/","/g')\""
fi

if test -n "$DIRECTIP"; then
	DIRECTIP=",\"$(echo $DIRECTIP | sed 's/,/","/g')\""
fi

if test -n "$BLACKHOLE"; then
	BLACKHOLE=",\"$(echo $BLACKHOLE | sed 's/,/","/g')\""
fi

cat $SCRIPTDIR/config-xray.json.tmpl \
	| sed "s#<SERVER>#$server#" \
	| sed "s#<BLACKHOLE>#$BLACKHOLE#" \
	| sed "s#<DIRECTIP>#$DIRECTIP#" \
	| sed "s#<DIRECTDOMAIN>#$DIRECTDOMAIN#" \
	> $SCRIPTDIR/config-xray.json

xray run -config $SCRIPTDIR/config-xray.json
