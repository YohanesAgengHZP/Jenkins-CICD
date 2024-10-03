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
                    // Stop and remove the container if it exists
                    sh '''
                        if [ $(docker ps -aq -f name=flask-app-test) ]; then
                            docker stop flask-app-test || true
                            docker rm flask-app-test || true
                        fi
                    '''
                    
                    // Run the Flask app container in detached mode
                    sh 'docker run -d -p 5000:5000 --name flask-app-test ghcr.io/yohanesagenghzp/testing-cicd:latest'
                    
                    // Wait for Flask app to start up and be ready
                    sleep 5 // Increase wait time for Flask app startup
                    
                    sh 'docker ps -a'
                    sleep 2
                    Check if the Flask app returns a 200 status code
                    script {
                        try {
                            // Check the status code and return an error if it's not 200
                            sh '''
                                STATUS=$(curl -o /dev/null -s -w "%{http_code}" http://localhost:5000/)
                                if [ "$STATUS" -ne 200 ]; then
                                    echo "Flask app returned status code $STATUS"
                                    exit 1
                                else
                                    echo "Flask app returned status code 200"
                                fi
                            '''
                        } catch (Exception e) {
                            // Print the Flask app logs if the test fails
                            sh 'docker logs flask-app-test'
                            error('Flask app did not return a 200 status code')
                        }
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
