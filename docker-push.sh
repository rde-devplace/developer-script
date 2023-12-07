#!/bin/sh

# env.properties에서 환경 변수 로드
while IFS='=' read -r key value
do
  # 빈 줄이나 주석(#)을 무시
  if [[ ! $key =~ ^\s*# ]] && [[ -n $key ]]; then
    eval export "$key"="$value"
  fi
done < env.properties

# Docker 이미지 빌드
docker build --tag ${IMAGE_NAME}:${VERSION} ${DOCKER_CACHE} --platform=linux/amd64 --build-arg JAR_FILE=${JAR_FILE_PATH} .
docker tag  ${IMAGE_NAME}:${VERSION} ${DOCKER_REGISTRY}/${IMAGE_NAME}:${VERSION}
#docker build -t ${DOCKER_REGISTRY}/${IMAGE_NAME}:${VERSION} --build-arg JAR_FILE=${JAR_FILE_PATH} .

# Docker 레지스트리에 로그인 (옵션: 이 스크립트를 실행하기 전에 미리 로그인해두어도 됩니다)
# docker login https://${DOCKER_REGISTRY}/ -u ${DOCKER_REGISTRY_USER} -p ${DOCKER_REGISTRY_PASSWORD}

# Docker 이미지 푸시
docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}:${VERSION}

