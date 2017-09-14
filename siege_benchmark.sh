#!/bin/bash

CONFIG_FILE=/etc/siege/siegerc
HAProxy_IP=172.16.1.14

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
		echo "Please ensure the siege configuration file exists"
		exit 1
	else
		echo "OK"
	fi
}


function siege_details {
	siege -V
}

function file_list {
	if [ ! -f $PWD/$1 ]; then
		echo "No file names found in $PWD/$1"
		exit 1
	else
		echo "OK"
	fi
}

if [ $# == 0 ]; then
	echo "Usage: ./siege_benchmark.sh <file_list>"
	exit 1
fi

echo -en "Checking user permissions..."
check_user

echo -en "Checking existence of configuration file..."
check_config_exists

echo "The details of the Siege being used are..."
siege_details

echo -en "Checking whether file list exists..."
file_list $1

#***************** Benchmarking for file size ****************************

echo "Starting Siege"
for i in `cat $PWD/$1`
do
	siege -c 1 -r 1 -R $CONFIG_FILE http://$HAProxy_IP/$i
done
