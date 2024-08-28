import boto3
import datetime

AWS_ACCESS_KEY_ID = 'access_key'
AWS_SECRET_ACCESS_KEY = 'secret_key'
REGION_NAME = 'us-west-1'

sts = boto3.client('sts', aws_access_key_id=AWS_ACCESS_KEY_ID,
                         aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
                         region_name=REGION_NAME)

#token duration in seconds
TOKEN_DURATION = 3600  # 1hr

# calcualte expiration date
now = datetime.datetime.now()
expiration = now + datetime.timedelta(seconds=TOKEN_DURATION)

#get the token
response = sts.get_federation_token(
    Name='expiring-token',
    Policy='arn:aws:iam::123456789012:policy/expiring-token-policy',
    DurationSeconds=TOKEN_DURATION
)

#extract the token from the response
token = response['Credentials']['AccessKeyId']

print(f'Expiring API token: {token}')
print(f'Expiration time: {expiration}')