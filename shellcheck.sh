for f in install-tools-*.sh; do
shellcheck "$f" -e 1090,1091,2016,2024,2086,2155,2317
done
