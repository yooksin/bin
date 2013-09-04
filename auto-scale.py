import boto
from boto.ec2.autoscale import Tag

# make sure your access keys are stored in ~/.boto
conn = boto.connect_autoscale()

# Assumes you already have an elastic load balancer and a launch configuration setup
ag = AutoScalingGroup(group_name=group_name, load_balancers=[load_balancer],
                          availability_zones=availability_zones,
                          launch_config=config, min_size=min_size, max_size=max_size)

# create auto scaling group
conn.create_auto_scaling_group(ag)

# fetch the autoscale group after it is created
auto_scaling_group = conn.get_all_groups(names=[group_name])[0]

# create a Tag for the austoscale group
as_tag = Tag(key='Name', value = 'as-instance', propagate_at_launch=True, resource_id=group_name)

# Add the tag to the autoscale group
conn.create_or_update_tags([as_tag])
