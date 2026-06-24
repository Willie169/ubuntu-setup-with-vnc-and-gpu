#!/bin/bash

clamscan -i --max-filesize=100G --max-scansize=1000G --recursive=yes --max-recursion=100 --max-files=100000 --max-dir-recursion=1000 /home /etc /var /usr/share /usr/local /opt /tmp
