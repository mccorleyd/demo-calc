pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY_CREDENTIALS = 'docker-hub-credentials'  // needs to be configured in Jenkins
        LINODE_SSH_CREDENTIALS = 'linode-ssh-credentials'  // needs to be configured in Jenkins
        LINODE_HOST = '139.162.198.94'  // will be replaced with actual IP
        
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
                    // First, create SSH config to disable host key checking
                    sh """
                        mkdir -p ~/.ssh
                        echo "StrictHostKeyChecking no" > ~/.ssh/config
                        chmod 600 ~/.ssh/config
                    """
                    
                    // Copy deployment files to Linode
                    sshagent([LINODE_SSH_CREDENTIALS]) {
                        sh """
                            # Create the deployment directory
                            ssh -o StrictHostKeyChecking=no root@${LINODE_HOST} 'mkdir -p /root/mortgage-calculator'
                            
                            # Copy deployment files
                            scp -o StrictHostKeyChecking=no docker-compose.prod.yml root@${LINODE_HOST}:/root/mortgage-calculator/
                            scp -o StrictHostKeyChecking=no deploy.sh root@${LINODE_HOST}:/root/mortgage-calculator/
                            
                            # Execute deployment script
                            ssh -o StrictHostKeyChecking=no root@${LINODE_HOST} 'cd /root/mortgage-calculator && chmod +x deploy.sh && VERSION=${VERSION} ./deploy.sh'
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
