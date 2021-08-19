#!/usr/bin/env bash
# health.sh
# nginx 연결 설정 변경 전 health-check 용도

ABSPATH=$(readlink -f $0)
ABSDIR=$(dirname $ABSPATH)
source ${ABSDIR}/profile.sh
source ${ABSDIR}/switch.sh

IDLE_PORT=$(find_idle_port)

echo "> Health Check Start!" >> /home/ubuntu/deploy/deploy.log
echo "> IDLE_PORT: $IDLE_PORT" >> /home/ubuntu/deploy/deploy.log
echo "> curl -s http://localhost:$IDLE_PORT/profile " >> /home/ubuntu/deploy/deploy.log
sleep 10

for RETRY_COUNT in {1..10}
do
  RESPONSE=$(curl -s http://localhost:${IDLE_PORT}/profile)
  UP_COUNT=$(echo ${RESPONSE} | grep 'real' | wc -l)

  if [ ${UP_COUNT} -ge 1 ]
  then
      echo "> Health check 성공" >> /home/ec2-user/log/deploy.log
      switch_proxy
      break
  else
      echo "> Health check의 응답을 알 수 없거나 혹은 실행 상태가 아닙니다." >> /home/ubuntu/deploy/deploy.log
      echo "> Health check: ${RESPONSE}" >> /home/ubuntu/deploy/deploy.log
  fi

  if [ ${RETRY_COUNT} -eq 10 ]
  then
    echo "> Health check 실패. " >> /home/ubuntu/deploy/deploy.log
    echo "> 엔진엑스에 연결하지 않고 배포를 종료합니다." >> /home/ubuntu/deploy/deploy.log
    exit 1
  fi

  echo "> Health check 연결 실패. 재시도..." >> /home/ubuntu/deploy/deploy.log
  sleep 10
done