# Create a Python AWS Lambda function that starts and stops an RDS instances using Boto3 and CloudWatch as a trigger.
Note: Just like 0.0 - Stop RDS instance, we just did some minor changes to start a ec2 instances

## EC2
- Deploy RDS instances using Terraform

## Lambda
- Used resource to us describe.filter... we can use the client, but it will have to change the whole code...
- Create function from scratch - Use Python 9.3 as your runtime - Add permission on resprective Lambda function (start and stop... see json files)
- Input your python code (Save, Deploy, and Test)
- Change timeout to 15 secs 

## CloudWatch
- StartRDS
 - Create a scheduled rule using cron expression set trigger every 6:00 AM GMT+8 cron(0 22 ? * * *) - Select your startRDS lambda function
- StopRDS
 - Create a scheduled rule using cron expression set trigger every 7:00 PM GMT+8 cron(0 11 ? * * *) - Select your stopRDS lambda function
