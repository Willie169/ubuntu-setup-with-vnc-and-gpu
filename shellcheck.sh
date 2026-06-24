#!/bin/bash
for f in *.sh; do
test -f "$f" && shellcheck "$f" -e 1090,1091
done
