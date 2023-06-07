#!/bin/bash

# Parse command line arguments
action=""
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --stop)
            action="stop"
            shift
            ;;
        --start)
            action="start"
            shift
            ;;
        --destroy)
            action="destroy"
            shift
            ;;
        *)
            echo "Invalid argument: $1"
            exit 1
            ;;
    esac
done

# Function to confirm user input
confirm() {
    read -r -p "$1 (y/n): " response
    case $response in
        [yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

# Stop instances
stop_instances() {
    instance_ids=$(aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`running`].InstanceId' --output text)
    for id in $instance_ids; do
        aws ec2 stop-instances --instance-ids "$id"
    done
}

# Start instances
start_instances() {
    instance_ids=$(aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`stopped`].InstanceId' --output text)
    for id in $instance_ids; do
        aws ec2 start-instances --instance-ids "$id"
    done
}

# Destroy instances
destroy_instances() {
    instance_ids=$(aws ec2 describe-instances --query 'Reservations[*].Instances[].InstanceId' --output text)
    for id in $instance_ids; do
        if confirm "Are you sure you want to destroy instance $id?"; then
            aws ec2 terminate-instances --instance-ids "$id"
        fi
    done
}

# Perform the specified action
case $action in
    stop)
        stop_instances
        ;;
    start)
        start_instances
        ;;
    destroy)
        destroy_instances
        ;;
    *)
        echo "Invalid action. Please specify --stop, --start, or --destroy."
        exit 1
        ;;
esac

