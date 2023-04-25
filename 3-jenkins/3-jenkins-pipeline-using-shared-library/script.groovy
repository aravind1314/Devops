def versioning() {
    sh "mvn build-helper:parse-version versions:set -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} versions:commit"
    def matcher = readFile("pom.xml") =~ "<version>(.+)</version>"
    def version = matcher[0][1]
    env.IMAGE_TAG = "$version-$BUILD_NUMBER"
}

def pushImage() {
    echo "pushing image to docker-hub"
    sh "docker push tma1314/docker-hub-repo:${IMAGE_TAG}"
    echo "push image successful"
}
return this
