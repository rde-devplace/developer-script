#!/bin/bash

# env.properties에서 환경 변수 로드
while IFS='=' read -r key value
do
  if [[ ! $key =~ ^\s*# ]] && [[ -n $key ]]; then
    eval export "$key"="$value"
  fi
done < env.properties

APP_NAME=${IMAGE_NAME}

# Deployment 이름으로부터 모든 POD 이름 추출
get_pod_names() {
  kubectl get pods -l app=$APP_NAME -o jsonpath='{.items[*].metadata.name}'
}

# 모든 POD가 Running 상태인지 확인
are_pods_running() {
  for pod in $(get_pod_names); do
    if [[ "$(kubectl get pod $pod -o jsonpath='{.status.phase}')" != "Running" ]]; then
      return 1
    fi
  done
  return 0
}

echo "----------- current pod list ----------"
kubectl get pods -l app=$APP_NAME
echo "----------------------------------------"

# 모든 POD가 Running 상태가 될 때까지 대기
while true; do
  if are_pods_running; then
    echo "All pods are in Running state."
    break
  else
    echo "Waiting for all pods to be in Running state..."
    sleep 1
  fi
done

# 첫 번째 POD의 로그 출력
POD_NAMES=($(get_pod_names))
kubectl logs -f "${POD_NAMES[0]}"

