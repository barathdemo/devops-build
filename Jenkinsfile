pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git branch: 'dev', url: 'https://github.com/Abisheak-create/devops-project.git'
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
                    sh 'docker build -t abisheak469/dev:$BUILD_NUMBER .'
                }
            }
        }
        stage('Docker Push') {
            steps {
                script {
                    sh 'docker push abisheak469/dev:$BUILD_NUMBER'
                }
            }
        }
        stage('Container run') {
            steps {
                script {
                    sh 'docker run -d -p 80:80 abisheak469/dev:$BUILD_NUMBER'
                }
            }
        }
    }
}