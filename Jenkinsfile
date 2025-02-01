pipeline{
    agent any
    tools{
        nodejs "nodejs"
    }
    stages{
        stage('fetch code'){
            steps{
                git branch:'main' , url:'https://github.com/osmaneTKT/tes-objectifs.git'
            }
        }
        stage('Install Dependencies') {
            steps {
                sh 'npm install'  // Installe les dépendances
            }
            post{
                success{
                    echo" installation reussie"
                }
            }
        }

    }


}