import boto3

# Define the connection /if want specify region add: region_name='your_region_name' 
rds = boto3.resource('rds')
 
def lambda_handler(event, context):
    # Use the filter() method of the instances collection to retrieve
    # all running rds instances.
    filters = [{
            'Name' : 'tag:Environment', 
            'Values': ['Staging']
        },
        {
            'Name': 'instance-state-name', 
            'Values': ['running']
        }]
    
    # Filter the and locate all running instances
    instances = rds.instances.filter(Filters=filters)
    instance_ids_to_stop = [instance.id for instance in instances]
    
    # Make sure there are actually instances to shut down. 
    if len(instance_ids_to_stop) > 0:
        try:    
            # Perform the shutdown
            shuttingDown = rds.stop_instances(InstanceIds=instance_ids_to_stop)
            print(f"Stopped {len(instance_ids_to_stop)} instances")
        except Exception as e:
            print(f"Error stopping instances: {e}")
    else:
        print ("Nothing to see here")

    return{
        'statusCode': 200,
        'statusMessage': 'OK'
    }