#! /bin/bash

set -e

SCRIPTDIR=$(dirname $0)

## PROXY_URL_FILE should contain an URL like:
##	https://your.site.com/subscribe?token=yoursecrettoken
PROXY_URL_FILE="$HOME/proxy.sub"

if ! grep -q '^https\?://' $PROXY_URL_FILE 2> /dev/null; then
	echo "No valid $PROXY_URL_FILE found" >&2
	exit 1
fi

proxy_url_tmp=$(mktemp)

echo "proxy URLs are stored in tmp file: $proxy_url_tmp"

curl -s $(cat $PROXY_URL_FILE) > $proxy_url_tmp

rm -rf "$SCRIPTDIR/db-xray"
mkdir "$SCRIPTDIR/db-xray"

id=0
for l in $(base64 -d $proxy_url_tmp); do
	idstr=$(printf "%03d" $id)
	p="$SCRIPTDIR/db-xray/$idstr"
	mkdir -p "$p"
	case "$l" in
	ss://*)
		$SCRIPTDIR/parse-url-ss.sh $l > "$p/server" 3> "$p/tag";;
	vless://*)
		$SCRIPTDIR/parse-url-vless.sh $l > "$p/server" 3> "$p/tag";;
	esac
	echo "$idstr: $(cat "$p/tag" 2>/dev/null)"
	((id++)) || true	# no need for `|| true` without `set -e`
done

rm $proxy_url_tmp
