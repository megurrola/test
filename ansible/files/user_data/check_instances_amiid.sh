#!/bin/bash

MY_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
MY_AMI=`aws ec2 --region ap-southeast-1 describe-instances --instance-ids $MY_ID --query "Reservations[*].Instances[*].[ImageId]" --output text`
MY_ASG=`aws ec2 describe-tags --filters "Name=resource-id,Values=$MY_ID" "Name=key,Values=aws:autoscaling:groupName" --region ap-southeast-1 --output text|cut -f5`
INSTANCES_IN_MY_ASG=`aws autoscaling describe-auto-scaling-instances --region ap-southeast-1 --output text --query "AutoScalingInstances[?AutoScalingGroupName=='$MY_ASG'].InstanceId"`

for INSTANCE in $INSTANCES_IN_MY_ASG
do
INSTANCE_AMI=`aws ec2 describe-instances --instance-ids $INSTANCE --region ap-southeast-1 --output text --query Reservations[].Instances[].ImageId`
if [ $INSTANCE_AMI != $MY_AMI ]; then
  INSTANCE_IP=aws ec2 describe-instances --instance-ids $INSTANCE  --region ap-southeast-1  --query Reservations[].Instances[].ImageId --query Reservations[].Instances[].PrivateIpAddress
  ssh -o StrictHostKeyChecking=no $INSTANCE_IP service nginx stop
fi
done
