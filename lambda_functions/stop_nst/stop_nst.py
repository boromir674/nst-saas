"""Handles events by stopping the NST Task on the ECS Cluster"""
import boto3
import os


# Initialize the aws object
ecs = boto3.client('ecs')


def lambda_handler(event, context):
    # Service Discovery: Get Service URI (ie URL/arn) from env varsbucket and object key from environment variables
    nst_service = os.getenv("NST_SERVICE")

    try:
        # Stop the Containerized NST Process/Task
        response = ecs.stop_task(
            cluster='default',
            task=nst_service,
            reason='User Requested'
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
        print(f"Error Stopping NST Service Task: {e}")
        return {
            "status": "error",
            "message": str(e)
        }
