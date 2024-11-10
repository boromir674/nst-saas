import json
import boto3
import os
from botocore.exceptions import ClientError

def handler(event, context):
    # Check if queryStringParameters or object_name is missing
    if 'queryStringParameters' not in event or 'object_name' not in event['queryStringParameters']:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Missing required query parameter: object_name'})
        }

    s3_client = boto3.client('s3')
    # assuming we know what S3 bucket we want to use
    bucket_name = os.environ['BUCKET_NAME']
    # assuming we know we are provided with the object name
    object_name = event['queryStringParameters'].get('object_name')
    expiration = int(os.environ.get('URL_EXPIRATION', 3600))  # Default to 1 hour

    try:
        # Generate a presigned URL for the S3 bucket
        response = s3_client.generate_presigned_url(
            'put_object',
            Params={'Bucket': bucket_name, 'Key': object_name},
            ExpiresIn=expiration
        )
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

    return {
        'statusCode': 200,
        'body': json.dumps({'presigned_url': response})
    }
