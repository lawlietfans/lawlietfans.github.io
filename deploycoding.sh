#!/bin/bash
rm -rf ../lawlietfans/* #centos will not delete `.` folder/file
cp -r public/* ../lawlietfans/

#push
cd ../lawlietfans
git add --all
git commit -m 'autodeploy'
git push origin master
