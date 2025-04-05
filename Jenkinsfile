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
                checkout scm
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    def branch = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()
                    echo "Current Branch: ${branch}"

                    if (branch == 'dev') {
                        sh "docker build -t ${DEV_IMAGE}:${IMAGE_TAG} ."
                        sh "docker push ${DEV_IMAGE}:${IMAGE_TAG}"
                    } else if (branch == 'master') {
                        sh "docker build -t ${PROD_IMAGE}:${IMAGE_TAG} ."
                        sh "docker push ${PROD_IMAGE}:${IMAGE_TAG}"
                    } else {
                        echo "No Docker push configured for this branch"
                    }
                }
            }
        }

        // 💬 This stage ensures any existing containers on port 8081 are stopped and removed
        stage('Cleanup Existing Containers (Only Dev)') {
            when {
                expression {
                    return sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim() == 'dev'
                }
            }
            steps {
                script {
                    sh '''
                    echo "Cleaning up any running containers on port 8081..."
                    CONTAINER_ID=$(docker ps -q --filter "publish=8081")
                    if [ ! -z "$CONTAINER_ID" ]; then
                        docker stop $CONTAINER_ID
                        docker rm $CONTAINER_ID
                    fi
                    '''
                }
            }
        }

        stage('Run Container (Only Dev)') {
            when {
                expression {
                    return sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim() == 'dev'
                }
            }
            steps {
                script {
                    sh "docker run -d -p 8081:80 ${DEV_IMAGE}:${IMAGE_TAG}"
                }
            }
        }
    }
}
