# developer-script
이 스크립트는 devplace의 빌드 및 배포를 위한 스크립트를 제공한다.

## 1 프로그램 별 환경 구성
각 diectory에서 env.properties를 설정해야 한다
예시는 다음과 같다

```
JAR_FILE_PATH="./target/ideoperators-0.0.1-SNAPSHOT.jar"
DOCKER_REGISTRY="amdp-registry.skamdp.org/mydev-ywyi"
DOCKER_REGISTRY_USER="xxxx"
DOCKER_REGISTRY_PASSWORD="xxx"
DOCKER_CACHE="--no-cache"
IMAGE_NAME="ide-operator"
VERSION="1.0.0"
DEPLOY_PATH="./k8s"
DEPLOY_FILE_NAME=deploy.yaml
```

## 2 k8s deploy 를 위한 template 구성하기
k8s/ 아래에 deploy.t 처럼 별도의 이름을 설정해야 한다. 

deploy.t 예시는 다음과 같다.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${IMAGE_NAME}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${IMAGE_NAME}
  template:
    metadata:
      annotations:
        prometheus.io/scrape: 'true'
        prometheus.io/port: '8081'
        prometheus.io/path: '/actuator/prometheus'
        update: ${HASHCODE}
      labels:
        app: ${IMAGE_NAME}
    spec:
      imagePullSecrets:
      - name: harbor-registry-secret
      containers:
      - name: ${IMAGE_NAME}
        image: ${DOCKER_REGISTRY}/${IMAGE_NAME}:${VERSION}
        imagePullPolicy: Always
        securityContext:
            runAsUser: 0
            privileged: true

```

## 3. 실행하기
devplace-operator, devplace-proxy, devplace-frontend 등에서 
cicd.sh를 실행하면 되며, 세부 파라메터는 다음과 같다.
```
# PATH 추가
> export PATH=$PATH:${DEVPLACE_SCRIPT_PATH}

> cicd.sh
Usage: /Users/himang10/mydev/digital-devplace/developer-script/cicd.sh [-b|--build] [-p|--push] [-y|--yaml] [-d|--deploy] [-a|--all]
  -b, --build    Build exec file
  -p, --push     Build docker image and push docker image to registry
  -y, --yaml     Convert .t files to .yaml
  -d, --deploy   Deploy docker to k8s cluster using generated .yaml files
  -a, --all      Run all steps in order
  
# build, push, yaml generation, deploy를 한번에 하고자 하는 경우 
> cicd.sh -a
```
특히 k8s 디렉토리에 *.t file 이 있는데, 이것은 Template으로 env.properties에 설정된 변수를 적용하여 deploy.yaml을 생성한다.
그러므로 cicd.sh -a 또는 cicd.sh -y 를 실행하여 deploy.yaml을 생성할 수 있다.

만약 기존의 *.yaml을 그대로 사용하고 싶을 경우에는 
- *.t를 삭제하거나 
- cicd.sh -a 대신 cicd.sh -b -p -d 

를 실행하면 된다.


