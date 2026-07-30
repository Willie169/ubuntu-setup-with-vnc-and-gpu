#!/usr/bin/env bash
for f in *.sh; do
	shfmt -w "$f"
	shellcheck "$f" -e 1090,1091
done
