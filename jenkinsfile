pipeline {
    agent any

    environment {
        // Replace with your GitHub username and repository details
        IMAGE_NAME = 'ghcr.io/YohanesAgengHZP/Jenkins-CICD.git:latest'
        DOCKER_CREDENTIALS_ID = 'PAT_CERT'  // Jenkins credential ID for GitHub PAT
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from GitHub
                git url: 'https://github.com/YohanesAgengHZP/Jenkins-CICD.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image from the Dockerfile in the repo
                    sh 'docker build -f Dockerfile-python -t testing-cicd:latest .'
                }
            }
        }

        stage('Login to GHCR') {
            steps {
                script {
                    // Log in to GHCR.io using the GitHub PAT
                    withCredentials([string(credentialsId: DOCKER_CREDENTIALS_ID, variable: 'PAT_CERT')]) {
                        sh 'echo $PAT_CERT | docker login ghcr.io -u YohanesAgengHZP --password-stdin'
                    }
                }
            }
        }

        stage('Push Docker Image to GHCR') {
            steps {
                script {
                    // Push the Docker image to GHCR.io
                    sh 'docker push testing-cicd:latest'
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    // Optional cleanup step to remove the local Docker image
                    sh 'docker rmi testing-cicd:latest'
                }
            }
        }
    }

    post {
        always {
            // Clean up workspace after build
            cleanWs()
        }
    }
}
