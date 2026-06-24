#!/bin/bash
for f in *.sh; do
test -f "$f" && shellcheck "$f"
done
