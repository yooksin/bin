#!/usr/bin/python  
# coding: utf8

import sys
from optparse import OptionParser
import boto, boto.ec2.elb

REGIONS = {
    # Tokyo
    "Tokyo"         : "ap-northeast-1",
    "tokyo"         : "ap-northeast-1",
    "ap-northeast-1": "ap-northeast-1",
    # Virginia
    "Virginia" : "us-east-1",
    "virginia" : "us-east-1",        
    "us-east-1": "us-east-1",
}

def die(reason):
    sys.stderr.write(reason + '\n')
    sys.exit(1)

def main():
    region = REGIONS[opts.region]

    try:
        elb = boto.ec2.elb.connect_to_region(region)
        balancer = elb.get_all_load_balancers(load_balancer_names=[opts.elb])[0]
    except:
        die("Could not connect to elb")

    # instance-idでinstanceを探す。instance-idが指定されていなければ、Nameでinstanceを探す。
    if opts.instance_id:
        try:
            instance_id = conn.get_all_instances(filters={'instance-id':opts.instance_id})[0].instances[0].id
        except:
            die("Could not find instance-id")

    if opts.debug:
        print "instance-id  : " + instance_id
        print "instance-name: " + opts.src_name
        print "dst name     : " + opts.dst_name        
        sys.exit()
                
    # Go
    try:
        conn.create_image(instance_id, opts.dst_name, description=None, no_reboot=opts.no_reboot)
    except:
        die("create_imate() is failed.")        

        
if __name__ == '__main__':
    parser = OptionParser()
    parser.add_option(
        "--region",
        dest="region",
        default="ap-northeast-1",
        help="The name of the region to connect to.")
    parser.add_option(
        "--elb",
        dest="elb",
        default="",         
        help="The name of the elb", metavar="elb")
    parser.add_option(
        "--instance-id",
        dest="instance_id",
        default="", 
        help="The ID of the src image.", metavar="src_name")
    parser.add_option(
        "-d", "--dst",
        dest="dst_name",
        help="The name of the new image", metavar="dst_name")
    parser.add_option(
        "--no_reboot",
        dest="no_reboot",
        action="store_true",
        default=False,
        help="not shutdown the instance before bundling.")
    parser.add_option(
        "--debug",
        dest="debug",
        action="store_true",
        default=False,
        help="Debug Mode.")
    opts, args = parser.parse_args()
    main()    


    
