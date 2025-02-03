def COLOR_MAP = [
    'SUCCESS': 'good', 
    'FAILURE': 'danger',
]
pipeline {
    agent any
    tools {
        nodejs "nodejs"  // Configure Node.js installé dans Jenkins
    }
    environment {
        registryCredential = 'ecr:us-east-1:awscreds'
        appRegistry = "340752842134.dkr.ecr.us-east-1.amazonaws.com/node-app"
        vprofileRegistry = "https://340752842134.dkr.ecr.us-east-1.amazonaws.com"
        cluster = "node-app-cluster"
        service = "nodeappservice3"

    }
    stages {
        stage('Fetch Code') {
            steps {
                echo 'Fetching code from repository...'
                git branch: 'main', url: 'https://github.com/osmaneTKT/tes-objectifs.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                sh 'npm install'  // Installe les dépendances Node.js
            }
        }

        stage('Lint Code') {
            steps {
                echo 'Running ESLint...'
                script {
                    def lintResult = sh(script: 'eslint . --ignore-pattern Dockerfile --format eslint-formatter-checkstyle --output-file eslint-report.xml --max-warnings=0', returnStatus: true)
                    if (lintResult != 0) {
                        echo 'ESLint found issues, but continuing...'
                    }
                }
            }

            post {
                always {
                    echo 'Archiving ESLint Report...'
                    archiveArtifacts artifacts: 'eslint-report.xml', fingerprint: true
                }
            }
        }


       

        stage('Package Application') {
            steps {
                echo 'Packaging application...'
                sh 'tar -czf app.tar.gz app.js package-lock.json package.json controllers/ models/ routes/ data/ views/ public/ node_modules/ util/'

                // Vérifie si le fichier app.tar.gz a été généré
                sh 'ls -l app.tar.gz'
            }

            post {
                success {
                    echo 'Archiving application package...'
                    archiveArtifacts artifacts: 'app.tar.gz', fingerprint: true
                }
                failure {
                    echo 'Packaging failed. Please check the logs.'
                }
            }
        }

        stage('Sonar Code Analysis') {
            environment {
                scannerHome = tool 'sonar6.2'  // Nom de l'outil configuré dans Jenkins
            }
            steps {
                echo 'Running SonarQube analysis...'
                withSonarQubeEnv('sonarserver') {  // Nom du serveur SonarQube configuré dans Jenkins
                    sh '''${scannerHome}/bin/sonar-scanner \
                        -Dsonar.projectKey=nodejs-app \
                        -Dsonar.projectName=nodejs-app \
                        -Dsonar.projectVersion=1.0 \
                        -Dsonar.sources=. \
                        -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info \
                        -Dsonar.eslint.reportPaths=eslint-report.xml'''
                }
            }
        }
        
        stage('Build App Image') {
            steps {
       
                script {
                    dockerImage = docker.build(appRegistry + ":$BUILD_NUMBER", "-f ./Dockerfile .")
                }
            }
        }

        stage('Upload App Image') {
            steps{
                script {
                    docker.withRegistry( vprofileRegistry, registryCredential ) {
                        dockerImage.push("$BUILD_NUMBER")
                        dockerImage.push('latest')
                    }
                }
            }
        }
        stage('Remove Container Images'){
            steps{
                sh 'docker rmi -f $(docker images -a -q)'
            }
        }
        stage('Deploy to ecs') {
            steps {
                withAWS(credentials: 'awscreds', region: 'us-east-1') {
                sh 'aws ecs update-service --cluster ${cluster} --service ${service} --force-new-deployment'
                }
            }
        }
    }
    post {
        always {
            echo 'Slack Notifications.'
            slackSend channel: '#devopscicd',
                color: COLOR_MAP[currentBuild.currentResult],
                message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
        }
    }
}
