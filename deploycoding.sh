#!/bin/bash
rm ../lawlietfans/*
cp -r public/* ../lawlietfans/

#push
git add --all
git commit -m 'autodeploy'
git push origin master
