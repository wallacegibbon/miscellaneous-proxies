#! /bin/sh

set -e

SCRIPTDIR=$(dirname $0)

a="$1"

# Extract components using POSIX-compatible methods
uuid=$(printf '%s' "$a" | sed -n 's|^vless://\([^@]*\)@.*|\1|p')
server=$(printf '%s' "$a" | sed -n 's|^vless://[^@]*@\([^:/?]*\).*|\1|p')
port=$(printf '%s' "$a" | sed -n 's|^vless://[^@]*@[^:]*:\([0-9]*\).*|\1|p')
params=$(printf '%s' "$a" | sed -n 's|^[^?]*?\([^#]*\).*|\1|p')
fragment=$(printf '%s' "$a" | sed -n 's|^[^#]*#\(.*\)|\1|p' | tr -d '\r')

# Parse query parameters
type=$(printf '%s' "$params" | tr '&' '\n' | grep '^type=' | cut -d= -f2)
security=$(printf '%s' "$params" | tr '&' '\n' | grep '^security=' | cut -d= -f2)
sni=$(printf '%s' "$params" | tr '&' '\n' | grep '^sni=' | cut -d= -f2)
pbk=$(printf '%s' "$params" | tr '&' '\n' | grep '^pbk=' | cut -d= -f2)
sid=$(printf '%s' "$params" | tr '&' '\n' | grep '^sid=' | cut -d= -f2)
fp=$(printf '%s' "$params" | tr '&' '\n' | grep '^fp=' | cut -d= -f2)
mux=$(printf '%s' "$params" | tr '&' '\n' | grep '^mux=' | cut -d= -f2)

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
						"flow": ""
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
