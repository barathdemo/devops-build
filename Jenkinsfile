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

        stage('Docker Compose Build & Push') {
            steps {
                script {
                    def branch = env.BRANCH_NAME
                    def imageName = branch == 'master' ? PROD_IMAGE : DEV_IMAGE

                    echo "Building and pushing image: ${imageName}:${IMAGE_TAG}"

                    // Override image name using build-arg and tag explicitly
                    sh """
                        IMAGE=${imageName}:${IMAGE_TAG} docker-compose build
                        docker tag ${imageName} ${imageName}:${IMAGE_TAG}
                        docker push ${imageName}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Cleanup Existing Containers') {
            steps {
                script {
                    def port = env.BRANCH_NAME == 'dev' ? '8081' : env.BRANCH_NAME == 'master' ? '8082' : ''
                    if (port) {
                        sh """
                            echo "Cleaning up containers on port ${port}..."
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

        stage('Run Container with Compose') {
            steps {
                script {
                    def port = env.BRANCH_NAME == 'dev' ? '8081' : env.BRANCH_NAME == 'master' ? '8082' : ''
                    def imageName = env.BRANCH_NAME == 'master' ? PROD_IMAGE : DEV_IMAGE

                    // Write override file dynamically
                    writeFile file: 'docker-compose.override.yml', text: """
                    version: '3.8'
                    services:
                      react_app:
                        image: ${imageName}:${IMAGE_TAG}
                        ports:
                          - "${port}:80"
                    """

                    // Run using both base + override
                    sh 'docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d'
                }
            }
        }
    }
}
