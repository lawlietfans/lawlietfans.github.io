#!/bin/bash
rm -rf ../lawlietfans/* #centos will not delete `.` folder/file
cp -r public/* ../lawlietfans/

#push
cd ../lawlietfans
#$ DATE=$(date +%Y-%m-%d)
#$ echo $DATE 
#2016-03-13
DATE=$(date)
git add --all
git commit -m "$DATE autodeploy"
git push origin master
