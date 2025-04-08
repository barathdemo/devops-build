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
                    def branch = env.BRANCH_NAME
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

        stage('Docker Compose Build & Push') {
            steps {
                script {
                    def composeFile = env.BRANCH_NAME == 'dev' ? 'docker-compose.dev.yml' :
                                      env.BRANCH_NAME == 'master' ? 'docker-compose.prod.yml' : null
                    def image = env.BRANCH_NAME == 'dev' ? env.DEV_IMAGE :
                                env.BRANCH_NAME == 'master' ? env.PROD_IMAGE : null

                    if (composeFile && image) {
                        echo "Using Compose File: ${composeFile}"
                        sh "docker-compose -f ${composeFile} build"
                        sh "docker tag ${image} ${image}:${IMAGE_TAG}"
                        sh "docker push ${image}:${IMAGE_TAG}"
                    } else {
                        echo "No Docker Compose build configured for this branch"
                    }
                }
            }
        }

        stage('Cleanup Existing Containers') {
            steps {
                script {
                    def port = env.BRANCH_NAME == 'dev' ? '8081' :
                               env.BRANCH_NAME == 'master' ? '8082' : ''
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

        stage('Deploy with Docker Compose') {
            steps {
                script {
                    def composeFile = env.BRANCH_NAME == 'dev' ? 'docker-compose.dev.yml' :
                                      env.BRANCH_NAME == 'master' ? 'docker-compose.prod.yml' : null

                    if (composeFile) {
                        sh "docker-compose -f ${composeFile} up -d"
                        sh "docker ps"
                    } else {
                        echo "No Compose file found for branch"
                    }
                }
            }
        }      
    }
}
