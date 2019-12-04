import boto3
from datetime import datetime
import logging
import time

logging.getLogger().setLevel(logging.INFO)
logger = logging.getLogger(__name__)


def lambda_handler(event, context):
    result = {}
    number_operations = 0
    number_failures = 0
    client = boto3.client('rds')
    instances = client.describe_db_instances()
    print("DATE and TIME (UTC) = " + str(datetime.utcnow()))
    for instance in instances['DBInstances']:
        tags = client.list_tags_for_resource(
            ResourceName=instance['DBInstanceArn'],
        )
        for tag in tags['TagList']:
            if tag['Key'] == 'powerdown' and instance['DBInstanceStatus'] == 'available' and instance['MultiAZ'] == False:
                hour = int(tag['Value'].split(":")[0])
                minu = int(tag['Value'].split(":")[1])
                days = tag['Value'].split(":")[2]
                print("TAG = " + tag['Value'])
                if datetime.utcnow().hour >= hour and datetime.utcnow().minute >= minu and str(datetime.utcnow().weekday()) in days:
                    print("****** Sleeping for 6 minutes and will check again ******")
                    time.sleep(360)
                    if instance['DBInstanceStatus'] == 'available' and instance['MultiAZ'] == False:
                        try:
                            print("Powering down " +
                                  instance['DBInstanceIdentifier'])
                            client.stop_db_instance(
                                DBInstanceIdentifier=instance['DBInstanceIdentifier'])
                            number_operations += 1
                        except:
                            print("FAILED Powering down " +
                                  instance['DBInstanceIdentifier'])
                            number_failures += 1
    result["result"] = "SUCCESS"
    result["number_operations"] = number_operations
    result["number_failures"] = number_failures
    logger.info(result)
    return result
