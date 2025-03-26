pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY_CREDENTIALS = 'docker-hub-credentials'  // needs to be configured in Jenkins
        LINODE_SSH_CREDENTIALS = 'linode-ssh-credentials'  // needs to be configured in Jenkins
        LINODE_HOST = 'your-linode-ip'  // will be replaced with actual IP
        
        MAIN_SERVICE_IMAGE = "dmwa14/mortgage-main-service"
        FINANCE_SERVICE_IMAGE = "dmwa14/mortgage-finance-service"
        
        VERSION = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Test') {
            steps {
                sh 'docker-compose build'
                sh 'docker-compose run main-service pytest'
                sh 'docker-compose run finance-service pytest'
            }
        }
        
        stage('Build and Push Docker Images') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: DOCKER_REGISTRY_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        // Login to Docker Hub
                        sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                        
                        // Build and push main service
                        sh """
                            docker build -t ${MAIN_SERVICE_IMAGE}:${VERSION} -t ${MAIN_SERVICE_IMAGE}:latest ./services/main_service
                            docker push ${MAIN_SERVICE_IMAGE}:${VERSION}
                            docker push ${MAIN_SERVICE_IMAGE}:latest
                        """
                        
                        // Build and push finance service
                        sh """
                            docker build -t ${FINANCE_SERVICE_IMAGE}:${VERSION} -t ${FINANCE_SERVICE_IMAGE}:latest ./services/finance_service
                            docker push ${FINANCE_SERVICE_IMAGE}:${VERSION}
                            docker push ${FINANCE_SERVICE_IMAGE}:latest
                        """
                    }
                }
            }
        }
        
        stage('Deploy to Linode') {
            steps {
                script {
                    // Copy deployment files to Linode
                    sshagent([LINODE_SSH_CREDENTIALS]) {
                        sh """
                            scp docker-compose.prod.yml root@${LINODE_HOST}:/root/mortgage-calculator/
                            scp deploy.sh root@${LINODE_HOST}:/root/mortgage-calculator/
                            ssh root@${LINODE_HOST} 'cd /root/mortgage-calculator && chmod +x deploy.sh && VERSION=${VERSION} ./deploy.sh'
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Clean up Docker images
            sh 'docker system prune -f'
            sh 'docker logout'
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
} 