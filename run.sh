#!/bin/bash

#!/bin/bash

while IFS='=' read -r key value
do
  # 빈 줄이나 주석(#)을 무시
  if [[ ! $key =~ ^\s*# ]] && [[ -n $key ]]; then
    eval export "$key"="$value"
  fi
done < env.properties

# 8080 포트를 사용 중인 프로세스 찾기
PID=$(lsof -ti :8080)

# 프로세스가 존재하면 종료
if [ ! -z "$PID" ]; then
  echo "8080 포트에서 실행 중인 프로세스 종료: PID $PID"
  kill -9 $PID
fi

# Java 애플리케이션 시작
echo "Java 애플리케이션 시작..."
java -jar ${JAR_FILE_PATH}

