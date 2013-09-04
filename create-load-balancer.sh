#!/bin/sh

aws elb create-load-balancer \
    --load-balancer-name elb-application \
    --listeners '{"instance_port": 25, "load_balancer_port": 25, "protocol": "TCP", "instanceprotocol": "TCP"}' \
    --availability-zones ap-northeast-1a ap-northeast-1c \
    --region ap-northeast-1

