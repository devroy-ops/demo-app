pipeline {
    agent any

    environment {
        APP_IMAGE = "devroy/demo-app"
        FRONTEND_IMAGE = "devroy/frontend"
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

        // ✅ BUILD DEMO APP IMAGE
        stage('Build Demo App Image') {
            steps {
                sh '''
                docker build --network=host -t $APP_IMAGE:$TAG . 
                '''
            }
        }

        // ✅ BUILD FRONTEND IMAGE (IMPORTANT FIX)
        stage('Build Frontend Image') {
            steps {
                sh '''
                docker build --network=host -t $FRONTEND_IMAGE:latest ./frontend
                '''
            }
        }

        // ✅ PUSH BOTH IMAGES
        stage('Push Docker Images') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                    docker push $APP_IMAGE:$TAG
                    docker push $FRONTEND_IMAGE:latest
                    '''
                }
            }
        }

        // ✅ UPDATE GITOPS REPO
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

                    # Update demo-app image
                    sed -i "s|image: devroy/demo-app:.*|image: $APP_IMAGE:$TAG|" deployment.yaml

                    # Update frontend image
                    sed -i "s|image:.*|image: $APP_IMAGE:$TAG|" deployment.yaml

                    git config user.email "ci@jenkins.com"
                    git config user.name "jenkins"

                    git add .
                    git commit -m "[skip ci] update images $TAG" || echo "no changes"

                    git push origin master
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ PIPELINE SUCCESS"
        }
        failure {
            echo "❌ PIPELINE FAILED"
        }
    }
}
  
