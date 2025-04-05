pipeline {
    agent any

    environment {
        DEV_IMAGE = 'barath2707/dev'
        PROD_IMAGE = 'barath2707/prod'
        IMAGE_TAG = "${BUILD_NUMBER}"
<<<<<<< HEAD
=======
        BRANCH_NAME = "${env.GIT_BRANCH ?: 'dev'}"
>>>>>>> dev
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
<<<<<<< HEAD
                    def branch = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()
                    echo "Current Branch: ${branch}"

                    if (branch == 'dev') {
                        sh "docker build -t ${DEV_IMAGE}:${IMAGE_TAG} ."
                        sh "docker push ${DEV_IMAGE}:${IMAGE_TAG}"
                    } else if (branch == 'master') {
=======
                    echo "Current Branch: ${BRANCH_NAME}"

                    if (BRANCH_NAME.contains('dev')) {
                        sh "docker build -t ${DEV_IMAGE}:${IMAGE_TAG} ."
                        sh "docker push ${DEV_IMAGE}:${IMAGE_TAG}"
                    } else if (BRANCH_NAME.contains('master')) {
>>>>>>> dev
                        sh "docker build -t ${PROD_IMAGE}:${IMAGE_TAG} ."
                        sh "docker push ${PROD_IMAGE}:${IMAGE_TAG}"
                    } else {
                        echo "No Docker push configured for this branch"
                    }
                }
            }
        }

<<<<<<< HEAD
        stage('Run Container (Only Dev)') {
            when {
                expression {
                    return sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim() == 'dev'
                }
            }
            steps {
                script {
                    sh "docker run -d -p 8081:80 ${DEV_IMAGE}:${IMAGE_TAG}"
=======
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
>>>>>>> dev
                }
            }
        }
    }
}
