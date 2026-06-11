pipeline {
  agent any

  environment {
    DOCKER_IMAGE = "devroyops/demo-app"
  }

  stages {

    stage('Checkout') {
      steps {
        git 'https://github.com/devroy-ops/demo-app.git'
      }
    }

    stage('Build Image') {
      steps {
        sh 'docker build -t $DOCKER_IMAGE:v1 .'
      }
    }

    stage('Login DockerHub') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'dockerhub-creds',
          usernameVariable: 'USER',
          passwordVariable: 'PASS')]) {
          sh 'echo $PASS | docker login -u $USER --password-stdin'
        }
      }
    }

    stage('Push Image') {
      steps {
        sh 'docker push $DOCKER_IMAGE:v1'
      }
    }
  }
}
