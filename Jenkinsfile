pipeline {
    agent any

    environment {
        GIT_REPO = "https://github.com/devroy-ops/demo-app.git"
        DOCKER_REPO = "devroy"
        IMAGE_NAME = "demo-app"
        GITOPS_REPO = "https://github.com/devroy-ops/demo-gitops.git"
    }

    stages {

        // ✅ CLEAN WORKSPACE
        stage('Clean Workspace') {
            steps {
                deleteDir()
            }
        }

        // ✅ CHECKOUT CODE (FROM demo-app)
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

        // ✅ BUILD IMAGE
        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t ${DOCKER_REPO}/${IMAGE_NAME}:${BUILD_NUMBER} .
                '''
            }
        }

        // ✅ PUSH IMAGE
        stage('Push Docker Image') {
            steps {
                sh '''
                docker push ${DOCKER_REPO}/${IMAGE_NAME}:${BUILD_NUMBER}
                '''
            }
        }

        // ✅ UPDATE GITOPS REPO (CORRECT WAY ✅)
        stage('Update GitOps Repo') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'git-creds',
                    usernameVariable: 'GIT_USER',
                    passwordVariable: 'GIT_PASS'
                )]) {
                    sh '''
                    echo "Cloning GitOps repo..."

                    rm -rf gitops
                    git clone https://${GIT_USER}:${GIT_PASS}@github.com/devroy-ops/demo-gitops.git gitops

                    cd gitops

                    echo "Updating deployment.yaml..."

                    sed -i "s|image:.*|image: ${DOCKER_REPO}/${IMAGE_NAME}:${BUILD_NUMBER}|" deployment.yaml

                    git config user.email "ci@jenkins.com"
                    git config user.name "jenkins"

                    git add deployment.yaml
                    git commit -m "[skip ci] Update image to ${BUILD_NUMBER}" || echo "No changes"

                    git push origin master
                    '''
                }
            }
        }

        // ✅ OPTIONAL: LOG ANALYSIS
        stage('AI Log Analysis') {
            steps {
                sh '''
                echo "Fetching logs from frontend pod..."

                POD=$(kubectl get pod -n default -l app=frontend \
                -o jsonpath="{.items[0].metadata.name}")

                echo "Selected Pod: $POD"

                kubectl logs -n default $POD > logs.txt || true

                echo "Running AI log analyzer..."
                python3 log_analyzer.py || true
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

