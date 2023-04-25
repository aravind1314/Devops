def buildJar() {
    echo "building the artifact"
    sh "mvn package"
}
def buildImage() {
    echo "building the image"
    sh "docker build -t tma1314/docker-hub-repo:2.0 ."
    echo "build image successful" 
}
def pushImage() {
    echo "pushing image to docker-hub"
    withCredentials([usernamePassword(credentialsId:'dockerhub-cred',usernameVariable:'usr',passwordVariable:'pwd')]){
        sh "echo ${pwd} | docker login -u ${usr} --password-stdin"
        sh "docker push tma1314/docker-hub-repo:2.0"
    }
    echo "push image successful"
}
return this

