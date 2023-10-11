To achieve this, you can use the boto3 library in Python for interacting with AWS services. Make sure you have the boto3 library installed:

Run it using Python, passing one of the commands as an argument:

python python.py list_s3_files

python python.py list_task_definition_versions

Make sure to replace 'my-nginx-bucket' with your actual S3 bucket name in the bucket_name variable. This script assumes that you're using the same AWS credentials that were used for creating the resources. If not, you might need to configure your AWS credentials in the environment where you run this script.

