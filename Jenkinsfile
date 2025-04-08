pipeline {
    agent any

    environment {
        DEV_IMAGE = 'barath2707/dev'
        PROD_IMAGE = 'barath2707/prod'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "Checking out branch: ${env.BRANCH_NAME}"
                    git branch: "${env.BRANCH_NAME}", url: 'https://github.com/barathdemo/devops-build.git'
                }
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                }
            }
        }

        stage('Build Docker Image & Push') {
            steps {
                script {
                    sh "./build.sh ${env.BRANCH_NAME} ${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Deploy Application') {
            steps {
                script {
                    sh "./deploy.sh ${env.BRANCH_NAME}"
                }
            }
        }
    }

    post {
        failure {
            echo "Build failed on branch ${env.BRANCH_NAME}"
        }
        success {
            echo "Successfully deployed ${env.BRANCH_NAME} branch!"
        }
    }
}
