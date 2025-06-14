#! /bin/bash

set -e
PROXY_URL_FILE="$HOME/proxy.sub"

## PROXY_URL_FILE should contain an URL like:
##	https://your.site.com/subscribe?token=yoursecrettoken

if ! grep -q '^https\?://' $PROXY_URL_FILE 2> /dev/null; then
	echo "No valid $PROXY_URL_FILE found" >&2
	exit 1
fi

SCRIPTDIR=$(dirname $0)

f() {
	awk -F ':' "{print \$$1}"
}

extract() {
	id=$(printf "%03d" $1)
	a=$(sed -n 's|^ss://\(.*\)@\(.*\):\([0-9]*\)#\(.*\)|\1:\2:\3:\4|p')

	method_pass=$(echo $a | f 1 | base64 -d)
	method=$(echo $method_pass | f 1)

	password=$(echo $method_pass | f 2)
	address=$(echo $a | f 2)
	port=$(echo $a | f 3)
	tagraw=$(echo $a | f 4 | tr -d '\r')
	tag=$(printf "%b\n" "${tagraw//%/\\x}")

	p="$SCRIPTDIR/db-v2ray/$id.$tag"
	mkdir "$p"

	printf '{"address":"%s", "method":"%s", "password":"%s", "port":%d}' \
		"$address" "$method" "$password" "$port" \
		> "$p/server"

	echo "$tag" > "$p/tag"
	echo $id: $tag
}

proxy_url_tmp=$(mktemp)

curl -s $(cat $PROXY_URL_FILE) > $proxy_url_tmp

rm -rf $SCRIPTDIR/db-v2ray
mkdir $SCRIPTDIR/db-v2ray

id=0
for l in $(cat $proxy_url_tmp | base64 -d | grep '^ss:'); do
 	printf "%s\n" "$l" | extract $id
	((id++)) || true	# no need for `|| true` without `set -e`
done

rm $proxy_url_tmp
