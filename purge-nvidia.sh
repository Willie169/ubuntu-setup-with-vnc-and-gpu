#!/usr/bin/env bash

list="$(dpkg-query -W -f='${binary:Package}\n' | grep -E '^.*nvidia.*$')"
list+=$'\n'
list+="$(dpkg-query -W -f='${binary:Package}\n' | grep -E '^.*cuda.*$')"
list="$(echo "$list" | sort | uniq | sed -Ez '$ s/\n+$//')"
list+=$'\n'
while true; do
	lastlist="$list"
	mapfile -t pkgs < <(echo "$lastlist")
	newlist=''
	for pkg in "${pkgs[@]}"; do
		newlist+="$(apt-cache rdepends --installed "$pkg" 2>/dev/null | sed -E '/^ *'"$pkg"'(:.*)?$/d; /^Reverse Depends:$/d; s/^[ |]*//')"
		newlist+=$'\n'
	done
	list+="$newlist"
	list="$(echo "$list" | sort | uniq | sed -Ez '$ s/\n+$//')"
	list+=$'\n'
	if [ "$list" = "$lastlist" ]; then
		break
	fi
done
list="$(echo "$list" | sort | uniq | sed -Ez '$ s/\n+$//')"
list+=$'\n'
mapfile -t pkgs < <(echo "$list")
if [ "$1" = '-i' ]; then
	sudo apt autoremove --purge "${pkgs[@]}"
else
	sudo apt autoremove --purge "${pkgs[@]}" -y
fi
