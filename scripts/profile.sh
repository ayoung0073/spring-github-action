#!/usr/bin/env bash

# profile.sh
# 미사용 중인 profile 를 찾는다.

function find_idle_profile()
{
RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/profile)

    if [ ${RESPONSE_CODE} -ge 400 ] # 400 보다 크면 (즉, 40x/50x 에러 모두 포함)
    then
        CURRENT_PROFILE=real2
    else
        CURRENT_PROFILE=$(curl -s http://localhost/profile)
    fi

    if [ ${CURRENT_PROFILE} == real1 ]
    then
      IDLE_PROFILE=real2
    else
      IDLE_PROFILE=real1
    fi

    echo "${IDLE_PROFILE}"
}

# 쉬고 있는 profile 의 port 찾기
function find_idle_port()
{
IDLE_PROFILE=$(find_idle_profile)

    if [ ${IDLE_PROFILE} == real1 ]
    then
      echo "8080" >> /home/ubuntu/deploy/deploy.log
    else
      echo "8081" >> /home/ubuntu/deploy/deploy.log
    fi
}