#! /bin/sh

set -e

SCRIPTDIR=$(dirname $0)

# Extract components using POSIX-compatible methods
uuid=$(printf '%s' "$1" | sed -n 's|^vless://\([^@]*\)@.*|\1|p')
server=$(printf '%s' "$1" | sed -n 's|^vless://[^@]*@\([^:/?]*\).*|\1|p')
port=$(printf '%s' "$1" | sed -n 's|^vless://[^@]*@[^:]*:\([0-9]*\).*|\1|p')
rawparams=$(printf '%s' "$1" | sed -n 's|^[^?]*?\([^#]*\).*|\1|p')
fragment=$(printf '%s' "$1" | sed -n 's|^[^#]*#\(.*\)|\1|p' | tr -d '\r')

params=$(mktemp tmp.vlessparams.XXX)
printf '%s' "$rawparams" | tr '&' '\n' > $params

getparam()
{
	grep $1 $params | cut -d= -f2
}

type=$(getparam '^type=')
security=$(getparam '^security=')
sni=$(getparam '^sni=')
pbk=$(getparam '^pbk=')
sid=$(getparam '^sid=')
fp=$(getparam '^fp=')
mux=$(getparam '^mux=')
flow=$(getparam '^flow=')

rm $params

tag="$($SCRIPTDIR/decodeurl.sh $fragment) [VLESS]"
echo "$tag" >&3

cat <<EOF
{
	"protocol": "vless",
	"settings": {
		"vnext": [
			{
				"address": "$server",
				"port": $port,
				"users": [
					{
						"id": "$uuid",
						"encryption": "none",
						"flow": "$flow"
					}
				]
			}
		]
	},
	"streamSettings": {
		"network": "${type:-tcp}",
		"security": "${security:-reality}",
		"realitySettings": {
			"serverName": "$sni",
			"publicKey": "$pbk",
			"shortId": "$sid",
			"fingerprint": "${fp:-chrome}"
		}
	},
	"tag": "PROXY"
}
EOF
