#!/bin/bash

OUT_DIR=$PWD/Results
mkdir -p $OUT_DIR

function check_user {
	if [ $(whoami) != "root" ]; then
		echo "Please run this script as root"
		exit 1
	else
		echo "OK"
	fi
}

function check_config_exists {
	if [ ! -f $PWD/$1 ]; then
		echo "Please place the HAProcy config file in $PWD"
		exit 1
	else
		echo "OK"
	fi
}

function check_ssl_certs {
	if [ ! -f /etc/ssl/certs/server.pem ]; then
		echo "Please create certificate to be used with SSL"
		exit 1
	else
		echo "OK"
	fi
}

function check_config_validity {
	haproxy -c -f $PWD/$1 1>/dev/null 2>/dev/null
	if [ $? != 0 ]; then
		echo "Please check your configuration file for errors"
		exit 1
	else
		echo "OK"
	fi
}

function haproxy_details {
	haproxy -vv
}

if [ $# == 0 ]; then
	echo "Usage: ./haproxy_benchmarks.sh <configuration_file>"
	exit 1
fi

echo -en "Checking user permissions..."
check_user

echo -en "Checking existence of configuration file..."
check_config_exists $1

echo -en "Checking validity of configuration..."
check_config_validity $1

echo -en "Checking existence of SSL certificates..."
check_ssl_certs

echo "The details of the HAProxy being benchmarked are..."
haproxy_details

netstat -ntulp|grep haproxy 1>/dev/null 2>/dev/null
if [ $? == 0 ]; then
	echo "HAProxy has been started"
else
	haproxy -f $1 -p /run/haproxy.pid 1>/dev/null 2>/dev/null
	netstat -ntulp|grep haproxy 1>/dev/null 2>/dev/null
	if [ $? == 0 ]; then
        	echo "HAProxy has been started"
	fi
fi
