#!/bin/sh


id=$(GET http://169.254.169.254/2012-01-12/meta-data/instance-id/)
name=kim
aws ec2 create-tags --resources $id --tags '{"key":"Name","value":"'$name'"}' >/tmp/create-tags.log 2>&1



