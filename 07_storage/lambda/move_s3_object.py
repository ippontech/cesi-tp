import boto3

def lambda_handler(event, context):
    s3 = boto3.resource('s3')
    bucketName = event['Records'][0]['s3']['bucket']['name']
    objectKey = event['Records'][0]['s3']['object']['key']
    targetBucketName = "ysimiandcossin-17122024-target"
    print(bucketName)
    print(objectKey)
    try:
        copy_source = {
            'Bucket': bucketName,
            'Key': objectKey
            }
        bucket = s3.Bucket(targetBucketName)
        bucket.copy(copy_source, objectKey)
        s3.Object(bucketName, objectKey).delete()
    except Exception as e:
        print("An exception occurred") 
        print(e)


