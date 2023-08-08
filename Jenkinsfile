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
    APPLICATION_NAME = "project02-production-in-place"
    DEPLOYMENT_GROUP_NAME = "project02-production-in-place"
    ECR_DOCKER_IMAGE = "${ECR_REPOSITORY}/${DOCKER_IMAGE_NAME}"
    ECR_DOCKER_TAG = "${DOCKER_TAG}"
    DEPLOY_CONFIG = "CodeDeployDefault.OneAtATime"
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
          sh 'aws s3 cp --region ap-northeast-2 --acl private ./deploy-1.0.zip s3://project02-terraform-status'
          sh 'rm -rf ./deploy-1.0.zip'
        }
      }
    }
    stage('CodeDeploy Deploy') {
      steps {
        script {
          def deploymentCmd = """
                              aws deploy push \
                              --application-name project02-production-in-place \
                              --description "This is Hello CodeDeploy Revision file" \
                              --ignore-hidden-files \
                              --s3-location s3://project02-terraform-status/deploy-1.0.zip \
                              --source .
                              """
          sh(deploymentCmd)
          def deploymentCmd2 = """
                               aws deploy create-deployment \ 
                               --application-name project02-production-in-place \
                               --s3-location bucket=project02-terraform-status,key=deploy-1.0.zip,bundleType=zip,eTag=5f3159ae1247c79b48df5102a4fcfca3 \
                               --deployment-group-name project02-production-in-place \
                               --deployment-config-name $DEPLOY_CONFIG \
                               --description "THIS IS CODEDEPLOY"
                               """
          sh(deploymentCmd2)
        }
      }
    }
  }
}
