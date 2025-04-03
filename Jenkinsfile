pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/barathdemo/devops-build.git'
            }
        }
        
        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'docker login -u "$DOCKER_USER" -p "$DOCKER_PASS"'
                }
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    sh 'docker build -t barath2707/dev:tagname .'
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    sh 'docker push barath2707/dev:tagname'
                }
            }
        }

        stage('Container run') {
            steps {
                script {
                    sh 'docker run -d -p 8081:80 barath2707/dev:tagname'
                }
            }
        }
    }
}
