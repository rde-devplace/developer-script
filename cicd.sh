#!/bin/bash

# 사용 방법을 출력하는 함수
usage() {
    echo "Usage: $0 [-b|--build] [-p|--push] [-y|--yaml] [-d|--deploy] [-a|--all]"
    echo "  -b, --build    Build exec file"
    echo "  -p, --push     Build docker image and push docker image to registry"
    echo "  -y, --yaml     Convert .t files to .yaml"
    echo "  -d, --deploy   Deploy docker to k8s cluster using generated .yaml files"
    echo "  -a, --all      Run all steps in order"
    exit 1
}

# 옵션 없이 스크립트를 실행한 경우 사용 방법 출력
if [ $# -eq 0 ]; then
    usage
fi

# 옵션 처리를 위한 변수
run_build=0
run_push=0
run_yaml=0
run_deploy=0
run_all=0

# 스크립트의 디렉토리 경로를 얻음
script_dir="$(dirname "$0")"
echo "script_dir $script_dir"


# 옵션 파싱
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -b|--build) run_build=1 ;;
        -p|--push) run_push=1 ;;
        -y|--yaml) run_yaml=1 ;;
        -d|--deploy) run_deploy=1 ;;
        -a|--all) run_all=1 ;;
        *) usage ;;
    esac
    shift
done


# 환경 변수 로드
if [[ -f env.properties ]]; then
    while IFS='=' read -r key value; do
        if [[ ! $key =~ ^\s*# ]] && [[ -n $key ]]; then
            eval export "$key=$value"
        fi
    done < env.properties
else
    echo "env.properties file not found."
    exit 1
fi

# 스크립트 실행
if [[ $run_build -eq 1 || $run_all -eq 1 ]]; then
    if [[ -n $JAR_FILE_PATH ]]; then
        ${script_dir}/build.sh
    fi
fi

if [[ $run_push -eq 1 || $run_all -eq 1 ]]; then
    "${script_dir}/docker-push.sh"
fi

if [[ $run_yaml -eq 1 || $run_all -eq 1 ]]; then
    # 해시코드 생성
    CURRENT_TIMESTAMP=$(date +%Y%m%d%H%M%S)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # MacOS에서 해시 코드 생성
        HASHCODE=$(echo -n "$CURRENT_TIMESTAMP$(cat env.properties)" | md5 | cut -d' ' -f4)
    else
        # 다른 운영 체제에서 해시 코드 생성
        HASHCODE=$(echo -n "$CURRENT_TIMESTAMP$(cat env.properties)" | md5sum | cut -d' ' -f1)
    fi

    for file in "${DEPLOY_PATH}"/*.t; do
        new_file="${file%.t}.yaml"
        sed -e "s#\${DOCKER_REGISTRY}#${DOCKER_REGISTRY}#g" \
            -e "s#\${IMAGE_NAME}#${IMAGE_NAME}#g" \
            -e "s#\${VERSION}#${VERSION}#g" \
            -e "s#\${HASHCODE}#${HASHCODE}#g" \
            -e "s#\${NAMESPACE}#${NAMESPACE}#g" \
            "$file" > "$new_file"
            cat "$new_file"
    done
fi

if [[ $run_deploy -eq 1 || $run_all -eq 1 ]]; then
    for file in "${DEPLOY_PATH}"/*.t; do
        new_file="${file%.t}.yaml"
        if [[ -f "$new_file" ]]; then
            kubectl apply -f "$new_file"
        fi
    done
fi

