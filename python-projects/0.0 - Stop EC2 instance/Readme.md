# Automating AWS: Stopping EC2 Instances on a Schedule with Lambda and CloudWatch.

## EC2
- Create a terraform script to deploy three EC2 instances

## Lambda:
- Create function from scratch - Use Python 9.3 as your runtime - Add permission (for testing: AmazonEC2FullAccess;AWSLambda_FullAccess) can change to more specific such as
>
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "StopEC2Instances",
        "Effect": "Allow",
        "Action": "ec2:StopInstances",
        "Resource": "arn:aws:ec2:*:*:instance/*"
        },
        {
        "Sid": "CloudWatchEvents",
        "Effect": "Allow",
        "Action": "events:PutEvents",
        "Resource": "arn:aws:events:*:*:event-bus/default"
        },
        {
        "Sid": "DescribeEC2Instances",
        "Effect": "Allow",
        "Action": "ec2:DescribeInstances",
        "Resource": "*"
        }
    ]
    }
- Input your python code (Save, Deploy, and Test)
- CHange timeout to 15 secs

## CloudWatch:
- Create a scheduled rule using cron expression set trigger every 7:00 PM GMT+8 cron(0 11 ? * * *) - Select your stopEC2 lambda function

Note: Can automate this using Terraform...

