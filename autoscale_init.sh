#!/bin/sh -vx

export AWS_CONFIG_FILE=/usr/local/etc/aws/aws.config
instance_id=$(GET http://169.254.169.254/2012-01-12/meta-data/instance-id/)
system_id=$(aws ec2 describe-instances --instance-ids $instance_id  | jq '.Reservations[].Instances[].Tags[] | .Key + ":" + .Value' | sed -n 's/"Project:\(.*\)"/\1/p')

sudo -u $system_id sh -c "cd /home/$system_id/server && git fetch origin && git checkout -q master && git submodule update"
sudo -u $system_id sh -c "cd /home/$system_id/system && git fetch origin && git checkout -q master"

if ["mentとかの判定"]
    /bin/ln -sf /home/$system_id/system/nginx/{production.conf,current.conf}
fi

