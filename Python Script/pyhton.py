import boto3

# Initialize the S3 and ECS clients
s3_client = boto3.client('s3')
ecs_client = boto3.client('ecs')

# Define the S3 bucket name
bucket_name = 'my-nginx-bucket'  # Replace with your actual bucket name

def list_s3_files():
    try:
        response = s3_client.list_objects(Bucket=bucket_name)
        files = [obj['Key'] for obj in response.get('Contents', [])]
        if files:
            print("Files in the S3 bucket:")
            for file in files:
                print(file)
        else:
            print("No files found in the S3 bucket.")
    except Exception as e:
        print(f"Error: {e}")

def list_task_definition_versions():
    try:
        response = ecs_client.list_task_definitions(familyPrefix='my-task', status='ACTIVE')
        task_definitions = response.get('taskDefinitionArns', [])
        if task_definitions:
            print("Task Definition Versions:")
            for definition in task_definitions:
                print(definition)
        else:
            print("No task definitions found.")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Manage S3 Bucket and ECS Task Definitions")
    parser.add_argument('command', choices=['list_s3_files', 'list_task_definition_versions'], help="Choose a command to execute")

    args = parser.parse_args()

    if args.command == 'list_s3_files':
        list_s3_files()
    elif args.command == 'list_task_definition_versions':
        list_task_definition_versions()

