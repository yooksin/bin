#!/bin/sh

export AWS_CONFIG_FILE=/usr/local/etc/aws/aws.config

name=auto-scale-aptest
id=$(GET http://169.254.169.254/2012-01-12/meta-data/instance-id/)
#aws ec2 create-tags --resources $id --tags '{"key":"Name","value":"'$name'"}' >/tmp/create-tags.log 2>&1
#service nginx start
