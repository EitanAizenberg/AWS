#!/bin/bash

# Get the instance IDs of all running instances
instance_ids=$(aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`running`].InstanceId' --output text)

# Stop each running instance
for id in $instance_ids; do
    aws ec2 stop-instances --instance-ids $id
done

