import json 
import boto3
import os

sns = boto3.client("sns")

SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]

def lambda_handler(event, context):
    print("Recieved event:")
    print(json.dumps(event, indent=2))

    instance_id = event["detail"]["instance-id"]
    state = event["detail"]["state"]
    region = event["region"]

    message = f"""
        Instance ID: {instance_id}
        State: {state}
        Region: {region}
    """

    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject="EC2 Instance Stopped",
        Message=message
    )

    return {
        "statusCode": 200,
        "body": "Notification sent successfully"
    }
