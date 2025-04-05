pipeline {
    agent any

    environment {
        DEV_IMAGE = 'barath2707/dev'
        PROD_IMAGE = 'barath2707/prod'
        IMAGE_TAG = "${BUILD_NUMBER}"
        BRANCH_NAME = "${env.GIT_BRANCH ?: 'dev'}"
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
                    echo "Current Branch: ${BRANCH_NAME}"

                    if (BRANCH_NAME.contains('dev')) {
                        sh "docker build -t ${DEV_IMAGE}:${IMAGE_TAG} ."
                        sh "docker push ${DEV_IMAGE}:${IMAGE_TAG}"
                    } else if (BRANCH_NAME.contains('master')) {
                        sh "docker build -t ${PROD_IMAGE}:${IMAGE_TAG} ."
                        sh "docker push ${PROD_IMAGE}:${IMAGE_TAG}"
                    } else {
                        echo "No Docker push configured for this branch"
                    }
                }
            }
        }

        // 💬 Ensure previous container on the dev or prod port is stopped before running a new one
        stage('Cleanup Existing Containers') {
            when {
                anyOf {
                    expression { return BRANCH_NAME.contains('dev') }
                    expression { return BRANCH_NAME.contains('master') }
                }
            }
            steps {
                script {
                    def port = BRANCH_NAME.contains('dev') ? "8081" : "8082"
                    sh """
                        echo "Cleaning up containers running on port ${port}..."
                        CONTAINER_ID=\$(docker ps -q --filter "publish=${port}")
                        if [ ! -z "\$CONTAINER_ID" ]; then
                            docker stop \$CONTAINER_ID
                            docker rm \$CONTAINER_ID
                        fi
                    """
                }
            }
        }

        // 💬 Run container for dev on port 8081, for master on port 8082
        stage('Run Container') {
            when {
                anyOf {
                    expression { return BRANCH_NAME.contains('dev') }
                    expression { return BRANCH_NAME.contains('master') }
                }
            }
            steps {
                script {
                    def image = BRANCH_NAME.contains('dev') ? DEV_IMAGE : PROD_IMAGE
                    def port = BRANCH_NAME.contains('dev') ? "8081" : "8082"
                    sh "docker run -d -p ${port}:80 ${image}:${IMAGE_TAG}"
                }
            }
        }
    }
}
