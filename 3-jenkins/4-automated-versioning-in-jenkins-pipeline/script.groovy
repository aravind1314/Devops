def versioning() {
    sh "mvn build-helper:parse-version versions:set -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} versions:commit"
    def matcher = readFile("pom.xml") =~ "<version>(.+)</version>"
    def version = matcher[0][1]
    env.IMAGE_TAG = "$version-$BUILD_NUMBER"
}

def buildJar() {
    echo "building the artifact"
    sh "mvn clean package"
}
def buildImage() {
    echo "building the image"
    sh "docker build -t tma1314/docker-hub-repo:${IMAGE_TAG} ."
    echo "build image successful"
}
def pushImage() {
    echo "pushing image to docker-hub"
    withCredentials([usernamePassword(credentialsId:'dockerhub-cred',usernameVariable:'usr',passwordVariable:'pwd')]){
        sh "echo ${pwd} | docker login -u ${usr} --password-stdin"
        sh "docker push tma1314/docker-hub-repo:${IMAGE_TAG}"
    }
    echo "push image successful"
}
def pushVersion() {
    echo "pushing new version pom.xml to gitlab-repo"
    sh "git add ."
    sh 'git commit -m "updating version in repo" '
    withCredentials([usernamePassword(credentialsId:'gitlab-cred',usernameVariable:'usr',passwordVariable:'pwd')]) {
        sh "git remote set-url origin https://${usr}:${pwd}@gitlab.com/aravind1314/versioning.git"
        sh "git push -u origin HEAD:main"
    }

}
return this
