# developer-script
개발 빌드 배포를 위한 스크립트를 작성한다. 
이것을 사용하기 위해서는 

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

## 3 유의 사항
cicd.sh  실행 시 -d | --deploy | -a | --all 로 했을 때 
k8s yaml을 기반으로 apply 하기 위해서는 
k8s 내 *.t file 이 존재해야 한다.
만약 기존 yaml 을 그대로 사용하고 싶으면 
yaml 을 .t로 변환하면 된다. 
예를 들어 deploy.yaml이 있는 경우 deploy.t로 전환하게 되면 cicd.sh 실행 시 deploy가 자동 실행된다.
