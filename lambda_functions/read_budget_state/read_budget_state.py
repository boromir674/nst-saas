import json
import boto3
import os

# Initialize the S3 client
s3_client = boto3.client("s3")


def lambda_handler(event, context):
    # Get bucket and object key from environment variables
    bucket_name = os.getenv("STATE_BUCKET_NAME")
    object_key = os.getenv("STATE_OBJECT_KEY")

    try:
        # Fetch the state object from S3
        response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
        
        # Read and parse the object content as JSON
        state_data = json.loads(response["Body"].read().decode("utf-8"))

        # Example: Extract budget status
        budget_status = state_data.get("budget_status", "unknown")
        remaining_budget = state_data.get("remaining_budget", 0)

        # Return parsed data
        return {
            "status": "success",
            "budget_status": budget_status,
            "remaining_budget": remaining_budget
        }

    except Exception as e:
        # Log and return an error if reading fails
        print(f"Error reading state from S3: {e}")
        return {
            "status": "error",
            "message": str(e)
        }
