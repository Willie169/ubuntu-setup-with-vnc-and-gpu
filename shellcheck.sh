for f in install-tools-*.sh; do
shellcheck "$f" -e 1091,2016,2024,2086
done
