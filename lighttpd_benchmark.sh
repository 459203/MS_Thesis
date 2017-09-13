#!/bin/bash

OUT_DIR=/var/www/lighttpd
CONFIG_FILE=/etc/lighttpd/lighttpd.conf

function check_user {
	if [ $(whoami) != "root" ]; then
		echo "Please run this script as root"
		exit 1
	else
		echo "OK"
	fi
}

function check_config_exists {
	if [ ! -f $CONFIG_FILE ]; then
		echo "Please ensure the lighttpd configuration file is placed in $CONFIG_FILE"
		exit 1
	else
		echo "OK"
	fi
}

function check_config_validity {
	lighttpd -t -f $CONFIG_FILE 1>/dev/null 2>/dev/null
	if [ $? != 0 ]; then
		echo "Please check your configuration file for errors"
		exit 1
	else
		echo "OK"
	fi
}

function lighttpd_details {
	lighttpd -v
}

#if [ $# == 0 ]; then
#	echo "Usage: ./lighttpd_benchmarks.sh <configuration_file>"
#	exit 1
#fi

echo -en "Checking user permissions..."
check_user

echo -en "Checking existence of configuration file..."
check_config_exists

echo -en "Checking validity of configuration..."
check_config_validity

echo -en "Checking existence of SSL certificates..."
check_ssl_certs

echo "The details of the Lighttpd being used are..."
lighttpd_details

echo "Creating test files..Please Wait!"
for i in 100 500 1000 #10000 100000 1000000
do
	[ -f "$OUT_DIR/File_$i" ] || dd if=/dev/urandom of="$OUT_DIR/File_$i" bs=1000 count=$i
done

echo "Starting the lighttpd daemon"
lighttpd -f $CONFIG_FILE 1>/dev/null 2>/dev/null
netstat -ntulp|grep lighttpd 1>/dev/null 2>/dev/null
if [ $? == 0 ]; then
	echo "Lighttpd web server started successfully"
else
	echo "Unable to start lighttpd..Sorry!"
	exit 1
fi
