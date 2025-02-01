pipeline {
    agent any
    tools {
        nodejs "nodejs"  // Configure Node.js installé dans Jenkins
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
                    def lintResult = sh(script: 'npm run lint', returnStatus: true)
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
                sh 'tar -czf app.tar.gz app.js package-lock.json package.json controllers/ models/ routes/ views/ public/ util/'

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
    }
}
