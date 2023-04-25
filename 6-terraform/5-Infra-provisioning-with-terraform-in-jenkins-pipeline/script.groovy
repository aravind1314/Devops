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
    sh "docker build -t ${REPO_URL}:${IMAGE_TAG} ."
    echo "build image successful"
}
def pushImage() {
    echo "pushing image to docker-hub"
    withCredentials([usernamePassword(credentialsId:'dockerhub-cred',usernameVariable:'usr',passwordVariable:'pwd')]){
        sh "echo ${pwd} | docker login -u ${usr} --password-stdin"
        sh "docker push ${REPO_URL}:${IMAGE_TAG}"
    }
    echo "push image successful"
}
def provisionServer() {
    echo "provisioning server"
    dir("terraform") {
        sh "terraform init"
        sh "terraform apply -auto-approve"
        env.EC2_PUBLIC_IP = sh(
            script: "terraform output ec2_public_ip",
            returnStdout: true
        ).trim()
    }
}
def deploy() {
    echo "ssh login to ec2"
    sleep(time: 120, unit: "SECONDS")
    def cmnds = "./script-cmnds.sh ${REPO_URL} ${IMAGE_TAG} ${DOCKER_CREDS_USR} ${DOCKER_CREDS_PSW}"
    def perm = " chmod +x script-cmnds.sh"
    sshagent(['aws-ssh-key']) {
        sh "scp -o StrictHostKeyChecking=no script-cmnds.sh ubuntu@${EC2_PUBLIC_IP}:/home/ubuntu/"
        sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ubuntu@${EC2_PUBLIC_IP}:/home/ubuntu/"
        sh "ssh -o StrictHostKeyChecking=no ubuntu@${EC2_PUBLIC_IP} ${perm}"
        sh "ssh -o StrictHostKeyChecking=no ubuntu@${EC2_PUBLIC_IP} ${cmnds}"
    }
    echo "deploy is successful"
}
 
def pushVersion() {
    echo "pushing new version pom.xml to gitlab-repo"
    sh "git add ."
    sh 'git commit -m "updating version in repo" '
    withCredentials([usernamePassword(credentialsId:'gitlab-cred',usernameVariable:'usr',passwordVariable:'pwd')]) {
        sh "git remote set-url origin https://${usr}:${pwd}@gitlab.com/aravind1314/deploy-to-ec2.git"
        sh "git push -u origin HEAD:main"
    }
    echo "update version successful"

}

return this
