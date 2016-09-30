#!/bin/bash
if [ "$1" = '' ]
then
    echo "ERROR: you need input param which stands for commit msg"
    exit 1;
elif [ "$1" = 'push' ]
then
    git push origin --all
    exit 1;
elif [ "$1" = '-h' ]
then
    echo "sh push.sh args1\nArgs1:\n\t-h\thelp\n\tpush\tpush only\n\tothers\tcommit msg\n"
    exit 1;
fi

git add --all
git commit -m "$1"
git push origin --all
