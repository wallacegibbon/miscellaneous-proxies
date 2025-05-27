#! /bin/bash

## ~/V2RAY.sub should contain an URL like:
##	https://your.site.com/subscribe?token=yoursecrettoken

if ! grep -q '^http' ~/V2RAY.sub 2> /dev/null; then
	echo "Valid ~/V2RAY.sub is not found" >&2
	exit 1
fi

SCRIPTDIR=$(dirname $0)

rm -rf $SCRIPTDIR/db
mkdir $SCRIPTDIR/db

f() {
	awk -F ':' "{print \$$1}"
}

extract() {
	id=$1
	a=$(sed -n 's|^ss://\(.*\)@\(.*\):\([0-9]*\)#\(.*\)|\1:\2:\3:\4|p')

	method_pass=$(echo $a | f 1 | base64 -d)
	method=$(echo $method_pass | f 1)

	password=$(echo $method_pass | f 2)
	address=$(echo $a | f 2)
	port=$(echo $a | f 3)
	tagraw=$(echo $a | f 4)
	tag=$(printf "%b\n" "${tagraw//%/\\x}")

	p="$SCRIPTDIR/db/$(printf "%03d" $id).$tag"
	mkdir "$p"

	printf '{"address":"%s", "method":"%s", "password":"%s", "port":%d}' \
		"$address" "$method" "$password" "$port" \
		> "$p/server"

	echo "$tag" > "$p/tag"
	echo $id: $tag
}

id=0

for l in $(curl -s $(cat ~/V2RAY.sub) | base64 -d | grep '^ss:'); do
 	printf "%s\n" "$l" | extract $id
	((id++))
done
