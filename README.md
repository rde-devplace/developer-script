# developer-script
개발 빌드 배포를 위한 스크립트를 작성한다. 
이것을 사용하기 위해서는 

각 diectory에서 env.properties를 설정해야 한다
예시는 다음과 같다
'''
JAR_FILE_PATH="./target/ideoperators-0.0.1-SNAPSHOT.jar"
DOCKER_REGISTRY="amdp-registry.skamdp.org/mydev-ywyi"
DOCKER_REGISTRY_USER="xxxx"
DOCKER_REGISTRY_PASSWORD="xxx"
DOCKER_CACHE="--no-cache"
IMAGE_NAME="ide-operator"
VERSION="1.0.0"
DEPLOY_PATH="./k8s"
DEPLOY_FILE_NAME=deploy.yaml
'''

