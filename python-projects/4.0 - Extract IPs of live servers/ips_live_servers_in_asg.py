import boto3

AWS_ACCESS_KEY_ID = 'YOUR_ACCESS_KEY_ID'
AWS_SECRET_ACCESS_KEY = 'YOUR_SECRET_ACCESS_KEY'
REGION_NAME = 'us-west-1'

asg_client = boto3.client('autoscaling', aws_access_key_id=AWS_ACCESS_KEY_ID,
                         aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
                         region_name=REGION_NAME)

# Set the Autoscaling group name
AS_GROUP_NAME = 'my-autoscaling-group'

# Get the Autoscaling group instances
response = asg_client.describe_auto_scaling_instances(
    AutoScalingGroupNames=[AS_GROUP_NAME]
)

# Extract the instance IDs
instance_ids = [instance['InstanceId'] for instance in response['AutoScalingInstances']]

# Create an EC2 client
ec2_client = boto3.client('ec2', aws_access_key_id=AWS_ACCESS_KEY_ID,
                         aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
                         region_name=REGION_NAME)

# Get the instance details
response = ec2_client.describe_instances(InstanceIds=instance_ids)

# Extract the public IPs of live instances
live_ips = []
for reservation in response['Reservations']:
    for instance in reservation['Instances']:
        if instance['State']['Name'] == 'running':
            live_ips.append(instance['PublicIpAddress'])

print("Live server IPs:")
for ip in live_ips:
    print(ip)