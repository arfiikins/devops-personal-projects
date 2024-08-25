import boto3

# Define the connection /if want specify region add: region_name='your_region_name' 
rds = boto3.resource('rds')
 
def lambda_handler(event, context):
    # Use the filter() method of the instances collection to retrieve
    # all stopped rds instances.
    filters = [{
            'Name' : 'tag:Environment', 
            'Values': ['Staging']
        },
        {
            'Name': 'instance-state-name', 
            'Values': ['stopped']
        }]
    
    # Filter the and locate all stopped instances
    instances = rds.instances.filter(Filters=filters)
    instance_ids_to_start = [instance.id for instance in instances]
    
    # Make sure there are actually instances to shut down. 
    if len(instance_ids_to_start) > 0:
        try:    
            # Perform the shutdown
            startingUp = rds.instances.filter(InstanceIds=instance_ids_to_start).start()
            print(f"Started {len(instance_ids_to_start)} instances")
        except Exception as e:
            print(f"Error starting instances: {e}")
    else:
        print ("Nothing to see here")

    return{
        'statusCode': 200,
        'statusMessage': 'OK'
    }