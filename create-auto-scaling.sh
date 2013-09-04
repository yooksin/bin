#!/bin/sh

create_launch_configuration()
{
    local conf_name=$1
    local image_id=$2
    local key_name=$3
    local sec_group=$4
    local instance_type=$5

    aws autoscaling create-launch-configuration \
	--launch-configuration-name ${conf_name} \
	--image-id ${image_id} \
	--instance-type ${instance_type} \
	--key-name ${key_name} \
	--security-groups ${sec_group} \
	--region ap-northeast-1 \
	--instance-monitoring '{"enabled": false}' \
	--user-data file:init_script.sh
}

delete_launch_configuration()
{
    aws autoscaling delete-launch-configuration \
	--launch-configuration-name as-config-application \
	--region ap-northeast-1
}


create_auto_scaling_group()
{
    aws autoscaling create-auto-scaling-group \
	--auto-scaling-group-name as-group-application \
	--launch-configuration-name as-config-application \
	--min-size 0 \
	--max-size 20 \
	--desired-capacity 0 \
	--availability-zones ap-northeast-1a ap-northeast-1c \
	--region ap-northeast-1 \
	--load-balancer-names elb-application
}

put_scale_out_policy()
{
    aws autoscaling put-scaling-policy \
	--policy-name as-scale-out-policy \
	--auto-scaling-group-name as-group-application \
	--scaling-adjustment 4 \
	--cooldown 300 \
	--adjustment-type ChangeInCapacity
    
}

put_scale_in_policy()
{
    aws autoscaling put-scaling-policy \
	--policy-name as-scale-in-policy \
	--auto-scaling-group-name as-group-application \
	--scaling-adjustment -2 \
	--cooldown 300 \	
	--adjustment-type ChangeInCapacity
}

update_auto_scaling_group()
{
    local new_config=$1
    
    aws autoscaling update-auto-scaling-group \
	--launch-configuration-name $new_config \
	--auto-scaling-group-name as-group-application
}

desired_capacity2zero()
{
    local group=$1
    local num=$2
    
    aws autoscaling update-auto-scaling-group \
	--auto-scaling-group-name $group \
	--desired-capacity $num \
	--region ap-northeast-1
}

update_tags()
{
    AWS_CREDENTIAL_FILE=/root/credential-as.txt
    #AWSAccessKeyId=XXX
    #AWSSecretKey=XXX
    
    tag="id=as-group-application, t=auto-scaling-group, k=Name, v=auto-scale-aptest, p=true"
    as-create-or-update-tags --tag $tag --region "ap-northeast-1"
}

# Go
#create_launch_configuration as-config-app-2013082203 ami-f7a83bf6
#update_auto_scaling_group as-config-app-2013082203
#create_auto_scaling_group
#put_scale_out_policy
#desired_capacity2zero as-group-application


case "$1" in
	update)
	        as_config=as-config-app-2013090402
		ami=ami-75d44974
		create_launch_configuration ${as_config} $ami aws-system-hg01 default m1.small
		update_auto_scaling_group   ${as_config}
		;;
	stop)
		if ! rh_status_q; then
			rm -f $lockfile
			exit 0
		fi
		stop
		;;
	desired)
	        num=$2
		desired_capacity2zero as-group-application $num
		;;
	reload)
		rh_status_q || exit 7
		reload
		;;
	force-reload)
		force_reload
		;;
	status)
		rh_status
		RETVAL=$?
		if [ $RETVAL -eq 3 -a -f $lockfile ] ; then
			RETVAL=2
		fi
		;;
	*)
		echo $"Usage: $0 {update|zero}"
		RETVAL=2
esac

