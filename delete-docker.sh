#!/bin/bash

# env.properties에서 환경 변수 로드
while IFS='=' read -r key value
do
  # 빈 줄이나 주석(#)을 무시
  if [[ ! $key =~ ^\s*# ]] && [[ -n $key ]]; then
    eval export "$key"="$value"
  fi
done < env.properties

docker rm $DOCKER_NAME &&
docker rmi $DOCKER_NAME:1.0
