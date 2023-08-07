pipeline {
  agent any
  tools {
    maven 'M3'
    jdk 'JDK11'
  }

  environment {
    AWS_CREDENTIALS_NAME = "AWSCredentials"
    REGION = "ap-northeast-2"
    DOCKER_IMAGE_NAME = "project02-spring-petclinic"
    DOCKER_TAG = "1.0"
    ECR_REPOSITORY = "257307634175.dkr.ecr.ap-northeast-2.amazonaws.com"
    AWS_SECRET_ACCESS_KEY = "wyVo/vt7idNXowMO4N1VggR5A/6CZrKxh39VXZVA"
    APPLICATION_NAME = "project02-production-in-place"
    DEPLOYMENT_GROUP_NAME = "project02-production-in-place"
    ECR_DOCKER_IMAGE = "${ECR_REPOSITORY}/${DOCKER_IMAGE_NAME}"
    ECR_DOCKER_TAG = "${DOCKER_TAG}"
  }
  
  stages {
    stage('Git Clone') {
      steps {
        git url: 'https://github.com/sfunzbob7/spring-petclinic.git', branch: 'efficient-webjars', credentialsId: 'project02_git_accept'
      }
    }
    stage('mvn build') {
      steps {
        sh 'mvn -Dmaven.test.failure.ignore=true install'
      }
      post {
        success {
          junit '**/target/surefire-reports/TEST-*.xml'
        }
      }
    }
    stage('Docker Image Build') {
      steps {
        dir("${env.WORKSPACE}") {
          sh 'docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} .'
        }
      }
    }
    stage('Push Docker Image') {
      steps {
        script {
          sh 'rm -f ~/.dockercfg ~/.docker/config.json || true'
          docker.withRegistry("https://${ECR_REPOSITORY}", "ecr:${REGION}:${AWS_CREDENTIALS_NAME}") {
            docker.image("${DOCKER_IMAGE_NAME}:${DOCKER_TAG}").push()
          }
        }
      }
    }
    stage('Upload to S3') {
      steps {
        dir("${env.WORKSPACE}") {
          sh 'zip -r deploy-1.0.zip ./scripts appspec.yml'
          sh 'aws s3 cp --region ap-northeast-2 --acl private ./deploy-1.0.zip s3://project02-terraform-bucket'
          sh 'rm -rf ./deploy-1.0.zip'
        }
      }
    }
    stage('CodeDeploy'){
      environment {
        # Set environment variables
        APPLICATION_NAME = ${env.APPLICATION_NAME}
        DEPLOYMENT_GROUP_NAME = ${env.DEPLOYMENT_GROUP_NAME}
            }
            
        steps {
          # Create deployment archive
          sh 'zip -r project02-deployment.zip .'

          # Deploy using CodeDeploy
          sh "aws deploy create-deployment --region ${env.REGION} --application-name ${env.APPLICATION_NAME} --deployment-group-name ${env.DEPLOYMENT_GROUP_NAME} --s3-location bucket=project02-terraform-bucket,key=project02-deployment.zip,bundleType=zip"
            }
        }
    }
}
