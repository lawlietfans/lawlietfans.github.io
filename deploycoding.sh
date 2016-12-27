#!/bin/bash
# 流程
# step1. rake generate  # 查看是否正确输出，md中语法错误会导致生成失败
# step2. auto deploy steps as follows：
# 1. deploy to github
rake deploy
# 2. copy and deploy to coding
rm -rf ../lawlietfans/* #centos will not delete `.` folder/file
cp -r public/* ../lawlietfans/

# 3. deploy to coding
cd ../lawlietfans
#$ DATE=$(date +%Y-%m-%d)
#$ DATE=$(date) utc time
#$ echo $DATE 
#2016-03-13
DATE=$(date +%Y-%m-%d" "%H:%M:%S)
git add --all
if [ "$1" = '' ] 
then
	git commit -m "$DATE autodeploy"
else
	git commit -m "$1"
fi
# please make sure branch is master
git push origin master
