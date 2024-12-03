"""Handles events by triggering the NST Elastic Container Service"""
import json
import boto3
import os


# Initialize the aws object
ecs = boto3.client('ecs')


def lambda_handler(event, context):
    # Service Discovery: Get Service URI (ie URL/arn) from env varsbucket and object key from environment variables
    nst_service = os.getenv("NST_SERVICE")

    try:
        # Start a Containerized NST Process
        response = ecs.run_task(
            cluster='default',
            taskDefinition=nst_service,
            launchType='FARGATE',
            networkConfiguration={
                'awsvpcConfiguration': {
                    'subnets': [
                        'subnet-12345678',
                        'subnet-23456789'
                    ],
                    'securityGroups': [
                        'sg-12345678'
                    ],
                    'assignPublicIp': 'ENABLED'
                }
            }
        )
        
        # Read and parse the object content
        data = response["tasks"][0]

        # Return parsed data
        return {
            "status": "success",
            "task_arn": data["taskArn"],
            "task_id": data["taskArn"].split("/")[-1]
        }

    except Exception as e:
        # Log and return an error if sth fails
        print(f"Error Starting NST Service, with Fargate: {e}")
        return {
            "status": "error",
            "message": str(e)
        }
