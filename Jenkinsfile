pipeline {
    agent any

    environment {
        IMAGE_NAME = "devroy/demo-app"
        TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Clean Workspace') {
            steps {
                deleteDir()
            }
        }

        stage('Checkout Code') {
            steps {
                git 'https://github.com/devroy-ops/demo-app.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $IMAGE_NAME:$TAG .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push $IMAGE_NAME:$TAG
                    '''
                }
            }
        }

        stage('Update GitOps Repo') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'git-creds',
                    usernameVariable: 'GIT_USER',
                    passwordVariable: 'GIT_PASS'
                )]) {
                    sh '''
                    rm -rf gitops
                    git clone https://${GIT_USER}:${GIT_PASS}@github.com/devroy-ops/demo-gitops.git gitops

                    cd gitops

                    sed -i "s|image:.*|image: $IMAGE_NAME:$TAG|" deployment.yaml

                    git config user.email "ci@jenkins.com"
                    git config user.name "jenkins"

                    git add deployment.yaml
                    git commit -m "[skip ci] update image $TAG" || echo "no changes"

                    git push origin master
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ SUCCESS"
        }
        failure {
            echo "❌ FAILED"
        }
    }
}
