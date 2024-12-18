pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'  // Change to your AWS region
        S3_BUCKET = 'sanju-server-artifact-bucket'  // Change to your S3 bucket name
        LAUNCH_TEMPLATE_ID = 'lt-001d825cde552be6f'  // Replace with your Launch Template ID
        ZIP_FILE_NAME = 'app.zip'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Checking out code...'
                git branch: 'master', url: 'https://github.com/RavanaDevs/sanju-server.git'
            }
        }

        stage('Zip Repository') {
            steps {
                echo 'Zipping the entire repository...'
                sh 'zip -r ${ZIP_FILE_NAME} *'
            }
        }

        stage('Upload to S3') {
            steps {
                echo 'Uploading zipped repository to S3...'
                withAWS(region: "${AWS_REGION}", credentials: 'aws-credentials-id') {
                    sh 'aws s3 cp ${ZIP_FILE_NAME} s3://${S3_BUCKET}/${ZIP_FILE_NAME}'
                }
            }
        }

        stage('Update Launch Template') {
            steps {
                echo 'Updating AWS Launch Template...'
                withAWS(region: "${AWS_REGION}", credentials: 'aws-credentials-id') {
                    sh '''
                    aws ec2 create-launch-template-version \
                        --launch-template-id ${LAUNCH_TEMPLATE_ID} \
                        --version-description "Deployed new app version from Jenkins" \
                        --source-version 1 \
                        --launch-template-data '{
                            "UserData": "'$(base64 -w0 << EOF
#!/bin/bash
apt-get update -y
install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" -y
apt-get update -y
apt-cache policy docker-ce
apt install docker-ce -y
apt install docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose -y
apt-get install awscli unzip -y
mkdir -p /home/ubuntu/deploy
cd /home/ubuntu/deploy
aws s3 cp s3://${S3_BUCKET}/${ZIP_FILE_NAME} /home/ubuntu/deploy/${ZIP_FILE_NAME}
aws s3 cp s3://${S3_BUCKET}/.env /home/ubuntu/deploy/.env
unzip ${ZIP_FILE_NAME}
docker-compose up -d
EOF
)'"
                        }'
                    '''
                }
            }
        }

        stage('Trigger ASG Instance Refresh') {
            steps {
                echo 'Triggering Auto Scaling Group instance refresh...'
                withAWS(region: "${AWS_REGION}", credentials: 'aws-credentials-id') {
                    sh 'aws autoscaling start-instance-refresh --auto-scaling-group-name "terraform-20241218065410481600000007"'
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment completed successfully!'
        }
        failure {
            echo '❌ Deployment failed. Check the logs for details.'
        }
    }
}
