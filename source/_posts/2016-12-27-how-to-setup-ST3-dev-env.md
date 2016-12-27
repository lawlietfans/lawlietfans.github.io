---
layout: post
title: Sublime Text3下快速搭建开发环境
date: 2016-12-27 12:00:00
comments: true
external-url:
categories: [tools]
---

原文链接：http://www.cnblogs.com/lawlietfans/p/6224824.html

安装好[Sublime Text3](http://www.sublimetext.com/3)之后，简单几步就可以搭建一个好用的开发环境。

sublime的设置包括自定义设置以及插件系统。

<!-- more -->

打开菜单`Preferences -> Settings`，编辑自定义设置（json格式）

```json
{
	"caret_style": "phase",
	"theme": "Spacegray.sublime-theme",
  "color_scheme": "Packages/Theme - Spacegray/base16-eighties.dark.tmTheme",
	"ensure_newline_at_eof_on_save": true,
	"font_face": "YaHei Consolas Hybrid",
	"font_size": 16,
	"format_on_save": true,
	"highlight_line": true,
	"highlight_modified_tabs": true,
	"rulers":
	[
		80,
		100
	],
	"tab_size": 2,
	"translate_tabs_to_spaces": true,
	"update_check": false
}
```


我们要通过Package Control安装需要的插件，所以首先安装Package Control

三种方法安装Package control：

1. `ctrl+shift+p`打开命令板，输入`pc`可以看到下拉列表出现`install package control`（模糊识别关键字）
2. 使用Ctrl+`快捷键或者通过View->Show Console菜单打开命令行，粘贴代码
3. 手动下载`Package Control.sublime-package`并复制到Installed Packages/目录

方法2、3详见[Sublime Text 3 安装Package Control](http://www.cnblogs.com/luoshupeng/archive/2013/09/09/3310777.html)


# 1 python开发者

python开发者可能需要如下插件：

- autosave：自动保存文件
- AutoPEP8：按照PEP规范调整你的python代码
- IMESupport：中文输入框跟随光标[1]
- SublimeREPL：sublime read–eval–print loop (REPL)插件
	- 通过菜单Tools->SublimeREPL->Python可以进入命令行环境
	- [键位绑定](https://www.zhihu.com/question/22904994)

安装插件gif图演示详见[1]

# 2 markdown编写

只需要满足高亮就可以了。许多博文，包括[2]提到[markdown editing](https://packagecontrol.io/packages/MarkdownEditing)插件，可我觉得实在是太难看了，和sublime黑色主题不搭。

这里强烈推荐spacegray主题。

- [theme spacegray](https://packagecontrol.io/packages/Theme%20-%20Spacegray)
	- 自动高亮Markdown关键字
  - 和sublime原来风格契合，可以同时使得sidebar主题也对应变化。

# References

1. http://www.cnblogs.com/figure9/p/sublime-text-complete-guide.html
2. http://www.cnblogs.com/jadeboy/p/5049340.html


