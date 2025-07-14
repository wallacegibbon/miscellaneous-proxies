#! /bin/sh

set -e

SCRIPTDIR=$(dirname $0)

a=$(printf "%s" "$1" \
	| sed -n 's|^ss://\(.*\)@\(.*\):\([0-9]*\)#\(.*\)|\1:\2:\3:\4|p')

f() {
	awk -F ':' "{print \$$1}"
}

method_pass=$(echo $a | f 1 | base64 -d)
method=$(echo $method_pass | f 1)

password=$(echo $method_pass | f 2)
address=$(echo $a | f 2)
port=$(echo $a | f 3)

tagraw=$(echo $a | f 4 | tr -d '\r')

tag="$($SCRIPTDIR/decodeurl.sh $tagraw) [SS]"
echo "$tag" >&3

cat <<EOF
{
	"protocol": "shadowsocks",
	"settings": {
		"servers": [
			{
				"address": "$address",
				"port": $port,
				"method": "$method",
				"password": "$password"
			}
		]
	},
	"tag": "PROXY"
}
EOF
