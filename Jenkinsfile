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
                    def branch = env.GIT_BRANCH?.replaceFirst(/^origin\//, '') ?: 'dev'
                    echo "Checking out branch: ${branch}"
                    git branch: "${branch}", url: 'https://github.com/barathdemo/devops-build.git'
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

        stage('Docker Build & Push') {
            steps {
                script {
                    def branch = env.BRANCH_NAME
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

        stage('Cleanup Existing Containers') {
            steps {
                script {
                    def port = env.BRANCH_NAME == 'dev' ? '8081' : env.BRANCH_NAME == 'master' ? '8082' : ''
                    if (port) {
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
        }

        stage('Run Container') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'dev') {
                        sh "docker run -d -p 8081:80 ${DEV_IMAGE}:${IMAGE_TAG}"
                    } else if (env.BRANCH_NAME == 'master') {
                        sh "docker run -d -p 8082:80 ${PROD_IMAGE}:${IMAGE_TAG}"
                    }
                }
            }
        }
    }
}
