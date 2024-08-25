import boto3
import datetime
import pytz

# init ec2 client
ec2 = boto3.client('ec2', region_name='your_region_name')

#define the business hours
business_hours_start = datetime.time(9, 0, 0)
business_hours_stop = datetime.time(18, 0, 0)
gmt8 = pytz.timezone('Etc/GMT-8')

def lambda_handler(event, context):
    # get the current gmt+8 time
    current_time = datetime.datetime.now(gmt8).time()

    # filter EC2 instances with tag Environment:Staging
    filters = [{'Name': 'tag:Environment', 'Values': ['Staging']}]
    instances = ec2.describe_instances(Filters=filters)['Reservations'][0]['Instances']

    # start or stop instances based on the current time
    if business_hours_start <= current_time <= business_hours_stop:
        # business hours, start instances
        instance_ids = [instance['InstanceId'] for instance in instances]
        ec2.start_instances(InstanceIds=instance_ids)
        print("Instances are started")
    else:
        # nonbusiness hours, stop instances
        instance_ids = [instance['InstanceId'] for instance in instances]
        ec2.stop_instances(InstanceIds=instance_ids)
        print("Shutting down all EC2 Instances")