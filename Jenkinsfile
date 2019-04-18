pipeline {
    agent { dockerfile true }
    stages {
        stage('Build') {
            steps {
                sh 'ballerina build'
            }
        }
        stage('Run') {
            steps {
                sh 'ballerina run /home/src/bal-hello-world/hello_service.bal & sleep 3'
            }
        }
        stage('Test') {
            steps {
                sh 'ballerina test --exclude-modules jenkins --sourceroot /home/src/bal-hello-world'
            }
        }
        stage('Publish API') {
            steps {
                sh './jenkins/deploy.sh'
            }
        }
    }
}
