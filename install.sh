#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit
fi

echo <<EOF
This is a setup script for Mac OS X.
EOF

$confirm = read -p "Do you want to continue? [y/N]" -n 1 -r

if [[ ! $confirm =~ ^[Yy]$ ]]; then
	exit
fi
