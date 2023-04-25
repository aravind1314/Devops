package com.example

class Docker implements Serializable{
    def script
    Docker(script) {
        this.script=script
    }
    def buildJar() {
        script.sh "mvn package"
    }
    def buildImage(String imageName) {
        script.sh "docker build -t $imageName ."
    }
    def dockerLogin() {
        script.withCredentials([script.usernamePassword(credentialsId:'dockerhub-cred',usernameVariable:'user',passwordVariable:'pwd')]) {
            script.sh "echo $script.pwd | docker login -u $script.user --password-stdin"
        }
    }
    def pushImage(String imageName) {
        script.sh "docker push $imageName"
    }
}
