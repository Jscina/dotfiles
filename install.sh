#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit
fi

echo <<EOF
This is a post-install script for MacOS. It sets up the system for my personal use. 
DO NOT RUN THIS SCRIPT IF YOU DO NOT KNOW WHAT IT DOES.
OR IF YOUR SYSTEM IS NOT A FRESH INSTALL.
EOF

$confirm = read -p "Do you want to continue? [y/N]" -n 1 -r

if [[ ! $confirm =~ ^[Yy]$ ]]; then
	exit
fi
