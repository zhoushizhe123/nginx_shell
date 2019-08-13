#!/usr/bin/env bash
# --------------------------------------------------------------------
# FileName：check_php_process_nums.sh
# DateTime：2019.08.13
# Author：Abu
# Description：该脚本用于获取php进程数并push到open-falcon。
# --------------------------------------------------------------------
code=`ps -aux | grep -i php | grep -v grep | wc -l`
curl -X POST -d "[{\"metric\": \"php-nums-\$code\", \"endpoint\": \"`hostname`\", \"timestamp\": `date +%s`,\"step\": 60,\"value\": 1,\"counterType\": \"GAUGE\",\"tags\": \"\"}]" http://127.0.0.1:1988/v1/pus
