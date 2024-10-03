pipeline {
    agent any

    environment {
        IMAGE_NAME = 'ghcr.io/YohanesAgengHZP/Jenkins-CICD.git:latest'
        DOCKER_CREDENTIALS_ID = 'PAT_CERT'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/YohanesAgengHZP/Jenkins-CICD.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -f Dockerfile-python -t ghcr.io/yohanesagenghzp/testing-cicd:latest .'
                }
            }
        }
        
        stage('Test Flask App') {
            steps {
                script {
                    // Run the Flask app container in detached mode
                    sh 'docker run -d -p 5000:5000 --name flask-app-test ghcr.io/yohanesagenghzp/testing-cicd:latest'
                    
                    // Wait for Flask app to start up and be ready
                    retry(5) { // Retry up to 5 times
                        sleep 3 // Wait for 3 seconds between each retry
                        sh 'curl -s http://localhost:5000 | grep "Hello, Jenkins CI/CD with Docker!"'
                    }
                }
            }
        }

        stage('Login to GHCR') {
            steps {
                script {
                    withCredentials([string(credentialsId: DOCKER_CREDENTIALS_ID, variable: 'PAT_CERT')]) {
                        sh 'echo $PAT_CERT | docker login ghcr.io -u yohanesagenghzp --password-stdin'
                    }
                }
            }
        }

        stage('Push Docker Image to GHCR') {
            steps {
                script {
                    sh 'docker push ghcr.io/yohanesagenghzp/testing-cicd:latest'
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    // Stop and remove the Flask app container
                    sh 'docker stop flask-app-test || true'
                    sh 'docker rm flask-app-test || true'
                    
                    // Optional: Remove the local Docker image
                    sh 'docker rmi ghcr.io/yohanesagenghzp/testing-cicd:latest || true'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
