pipeline {
    agent any
  
    environment {
        GIT_REPO = "https://github.com/devroy-ops/demo-gitops.git"
        DOCKER_REPO = "devroy"
        IMAGE_NAME = "demo-app"
    }

    stages {

        // ✅ CLEAN OLD WORKSPACE (VERY IMPORTANT)
        stage('Clean Workspace') {
            steps {
                deleteDir()
            }
        }

        // ✅ CLONE CODE
        stage('Checkout Code') {
            steps {
                git branch: 'master', url: "${GIT_REPO}"
            }
        }

        // ✅ DOCKER LOGIN
        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }

        // ✅ BUILD DOCKER IMAGE
        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t ${DOCKER_REPO}/${IMAGE_NAME}:${BUILD_NUMBER} .
                '''
            }
        }

        // ✅ PUSH DOCKER IMAGE
        stage('Push Docker Image') {
            steps {
                sh '''
                docker push ${DOCKER_REPO}/${IMAGE_NAME}:${BUILD_NUMBER}
                '''
            }
        }

        // ✅ UPDATE GITOPS REPO (FIXED ✅)
        stage('Update GitOps Repo') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'git-creds',
                    usernameVariable: 'GIT_USER',
                    passwordVariable: 'GIT_PASS'
                )]) {
                    sh '''
                    echo "Updating Kubernetes manifest..."

                    sed -i "s|image:.*|image: ${DOCKER_REPO}/${IMAGE_NAME}:${BUILD_NUMBER}|" deployment.yaml

                    git config --global user.email "ci@jenkins.com"
                    git config --global user.name "jenkins"

                    git add deployment.yaml

                    # ✅ SAFE COMMIT
                    git commit -m "[skip ci] Update image to ${BUILD_NUMBER}" || echo "No changes"

                    echo "Setting authenticated remote..."

                    git remote set-url origin https://${GIT_USER}:${GIT_PASS}@github.com/devroy-ops/demo-gitops.git

                    git remote -v

                    git push origin master
                    '''
                }
            }
        }

        // ✅ AI LOG ANALYSIS
        stage('AI Log Analysis') {
            steps {
                sh '''
                echo "Fetching logs from frontend pod..."

                POD=$(docker run --rm \
                -v /root/.kube:/root/.kube \
                bitnami/kubectl:latest \
                get pod -n default -l app=frontend \
                -o jsonpath="{.items[0].metadata.name}")

                echo "Selected Pod: $POD"

                docker run --rm \
                -v /root/.kube:/root/.kube \
                bitnami/kubectl:latest \
                logs -n default $POD > logs.txt

                echo "Running AI log analyzer..."
                python3 log_analyzer.py
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline SUCCESS"
        }
        failure {
            echo "🚨 Pipeline FAILED"
        }
        always {
            echo "Pipeline finished"
        }
    }
}
  
