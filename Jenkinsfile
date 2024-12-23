@Library('jenkins-sharedlibs-linux@Migration_Jenkins')
@Library('pipeline-utility-steps')_

pipeline{
    agent { label "linux" }

    tools{
        maven "maven-latest"
        jdk "jdk-21"
    }
    stages {
        stage('Test') {
            steps {
                mvnBuild(GOAL: "test")
            }
        }
        stage('build') {
            steps {
                mvnBuild(GOAL: "install", OPTIONS: "-DskipTests")
            }
        }
        stage('sonar') {
            steps {
                withSonarQubeEnv('sonar') {
                    mvnBuild(GOAL: "sonar:sonar", OPTIONS: "-DskipTests")
                }
            }
        }
        stage("Quality Gate") {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: false
                }
            }
        }
        stage('deploy') {
            steps {
                mvnBuild(GOAL: "deploy", OPTIONS: "-DskipTests")
            }
        }
    }
}
