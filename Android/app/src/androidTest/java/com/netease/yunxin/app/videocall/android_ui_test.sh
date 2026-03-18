#!/bin/bash
# Copyright (c) 2022 NetEase, Inc. All rights reserved.
# Use of this source code is governed by a MIT license that can be
# found in the LICENSE file.

set -x
# 自定义修改
selectPartNameList=[\"Case1\"]
platform="android"
appId="1006"

## 执行方式 ===========
# sh android_ui_test.sh "callkit" "1.4.0" "PBV7N16A12000656" "UJK0220410050250"
# "android1": "231129212745115",
#  "android2": "875914692556114"
# sh android_ui_test.sh "callkit" "1.3.4" "D5F7N18516008620" "UJK0220410050250"

###########################################
arr=$*
params=($arr)

adb="$HOME/Library/Android/sdk/platform-tools/adb"
host="59.111.31.178"
#host="10.242.148.84:9090"
caseId=""
echo "$adb"
#$adb devices
startRunning() {
    for i in $arr; do
      if [ "$i" == "" ]; then
        echo "当前参数为空 $i "
      else
        adb -s "${i}" shell am instrument -w -m   -e debug false -e class 'com.netease.yunxin.app.videocall.CallKitTestLauncher' com.netease.yunxin.app.videocall.test/androidx.test.runner.AndroidJUnitRunner  &    echo "start running $i "
      fi
    done
}

# CI接口使用
hasNextPart() {
  result=$(curl "http://${host}:9000/hasNextPart?deviceId=156487853555010" \
    -H 'Content-Type: application/json; charset=utf-8')

  value=$(parse_json "$result" "currentIndex")
  echo "$value"
}

# 默认支持两台设备，如果需要运行，需要注册手机设备@赵冲
#  "selectPartNameList": [],
dispatchDevice() {
result=$(curl -X "PUT" "http://${host}/caseGroup/dispatch" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{
  "platform":"'${platform}'",
  "selectPartNameList": '${selectPartNameList}',
  "appId": "'${appId}'",
  "version": "'${params[1]}'",
  "deviceIdMap":  {
    "android1": "'${params[2]}'",
    "android2":  "'${params[3]}'"
  },
  "env": "'${params[0]}'"
}')
  # shellcheck disable=SC2034
  taskId=$(parse_json "$result" "taskId")
  echo "===>>>taskId"
}
sendFirst() {
result=$(curl -X "POST" "http://${host}/push/start/$1/$2" \
     -H 'Content-Type: application/json; charset=utf-8')
   code=$(parse_json "$result" "code")
   echo "====$code"
}

executeCase() {
#  remoteIndex=$(hasNextPart)
#    if [[ $remoteIndex == "-1" ]]; then
#      sleep 3
#      echo "当前没有需要执行的用例了"
#      return
#    fi
    echo "***********exe nextPart start*********"
    startRunning
    echo "************exe nextPart end********"
}

parse_json(){
echo "${1//\"/}" | sed "s/.*$2:\([^,}]*\).*/\1/"
}

executeCase
sleep 6
dispatchDevice
sendFirst "$taskId"  "$caseId"
echo "all is ending"

