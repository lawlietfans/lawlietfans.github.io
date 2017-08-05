---
layout: post
title: MacOS 实用设置
date: 2017-xx-xx 12:00:00
comments: true
external-url:
categories: [x, xx]
---

# 1 办公

1.1 输入法

自带中文输入法中英切换需要按ctrl+space，很麻烦。

使用搜狗输入法，按shift切换中英文

1.2 删除光标后面的内容

按fn+DELETE

1.3 定时休息

http://www.dejal.com/timeout/

1.4 在Finder中查看隐藏文件、全路径

查看隐藏文件：

`$ defaults write com.apple.finder AppleShowAllFiles -bool true`

取消查看：

`$ defaults write com.apple.finder AppleShowAllFiles -bool false`

查看全路径：

`$ defaults write com.apple.finder _FXShowPosixPathInTitle -bool TRUE;killall Finder`

取消查看：

`$ defaults delete com.apple.finder _FXShowPosixPathInTitle;killall Finder`

# 2 shell

## 2.1 ssh连接到GitHub提示Permission denied (publickey).

>https://segmentfault.com/q/1010000000095149/a-1020000010281766

首先拷贝已有private key，接着通过ssh-add把key添加到authentication agent就可以了。

## 2.2 设置terminal颜色、自动补全忽略大小写

>http://blog.csdn.net/songjinshi/article/details/8945809


```sh
$ nano ~/.bash_profile
export CLICOLOR=1
export LSCOLORS=gxfxaxdxcxegedabagacad
```

```sh
$ nano .inputrc
set completion-ignore-case on
set show-all-if-ambiguous on
TAB: menu-complete
```


## 2.3 第三方shell：iTerm 2 && Oh My Zsh

>http://www.jianshu.com/p/7de00c73a2bb

>iterm2用法 https://www.zhihu.com/question/27447370

自带shell的缺点在于：

1. 不能`cmd+数字`切换terminal

...


快捷键：

1. cmd+enter 全屏显示

## 2.4 通过[homebrew](https://brew.sh/)安装其他工具

`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

安装需要的工具：`brew install wget`


