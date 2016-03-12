---
layout: post
title: 基于github pages与hexo搭建一个独立博客
date: 2015-11-08 17:08:22
comments: true
external-url:
categories:
tags: 博客搭建与配置
---

>原文地址：http://lawlietfans.github.io/2015/11/08/using-hexo-with-jekyll/  
>2015-11-15 theme update  
>原文备份到：http://lawlietfans.github.io/project-site-blogs/2015/11/08/using-hexo-with-jekyll/


介绍基于github pages搭建独立博客的博文已经有很多了，而本文旨在帮助读者了解基于github pages与hexo搭建一个独立博客的整体过程，顺便备忘。

在开始动手操作之前，我们应该了解
# 1 什么是github page？为什么要用hexo？
[github Pages可以被认为是用户编写的、托管在github上的静态网页][1],GitHub Pages分两种，一种是你的GitHub用户名建立的username.github.io这样的用户&组织页（站），另一种是依附项目的pages。 
即[organization site和project site][2].  
不过官方目前不建议用二级域名，我们这里的例子也是属于organization site.

至于hexo，快速、简洁且高效的博客框架，文档完善，主题丰富

# 2 配置organization site
 新增仓库：https://github.com/new

      Repository name：github账号.github.io
      Description：随便输入点描述
      public
      Initialize this repository with a README
      .gitignore 选择初始的文件忽略，我选的java
      Licenses：我选的NPL（GNU General Public License v2.0）
      配置

选择右侧操作区的settings

      选择Launch automatic page generator
      输入一些基本说明，非必要
      选择Load README.md
      继续Continue to layouts
      选择模板（随便选个）
      发布Publish page
      此时进入settings应该会有Your site is published at http://username.github.io的条提示，访问一下，神奇吧！
      如果404，请检查你的仓库名或账号名，删除仓库重来，删除也是在settings最底部

[参考-详细][5]

# 3 本地准备工作
[安装git][8]  
安装Node.JS

    安装完成后添加Path环境变量，使npm命令生效。新版已经会自动配置Path  
    ;C:\Program Files\nodejs\node_modules\npm

安装Hexo

    npm install hexo-cli -g
    npm install hexo --save

    #如果命令无法运行，可以尝试更换taobao的npm源
    npm install -g cnpm --registry=https://registry.npm.taobao.org
    #新建文件夹<folder>
    cd <folder>
    hexo init 
    npm install

运行

    $ hexo g
    $ hexo s

Git Bush或者Linux环境下terminal会提示输入http://0.0.0.0:4000  查看自带landspace主题效果

[参考-详细][6]


# 4 如何使用新主题，以[Jekyll主题](http://pinggod.com/)为例
[hexo提供的更多主题][7]提供了丰富的主题可以选择，安装方法大同小异，其中包括一款黑色背景的，好了，就它了。

安装插件

    npm install --save hexo-renderer-jade hexo-generator-feed

clone该主题到`<folder>/themes/jekyll`文件夹

    git clone https://github.com/pinggod/hexo-theme-jekyll.git themes/jekyll

修改<folder>/_config.yml的theme值

添加feed属性

复制Demo.md到source/_post文件夹

本地运行预览

配置[deploy属性][9]

    deploy:
      type: git
      repository: 前面步骤在github建好的Repository的地址
      branch: master

发布到远程    

    hexo d

最后就可以在yourname.github.io看到效果了    

个人觉得不错的其他主题：
- [jacman][10]    
- [pacman][11]

常用命令总结

    hexo new "postName" # 新建文章
    hexo new page "about" # 新建页面
    hexo generate #生成静态页面至public目录
    hexo server #开启预览访问端口（默认端口4000，'ctrl + c'关闭server）
    hexo deploy #将.deploy目录部署到GitHub
    hexo clean # 有时候配置没有立即生效需要删除cache

# 5 修改这个主题

## 5.1 添加新文章

    $ hexo new [layout] <title>
Layout包括：post、page 和 draft

Hexo 默认以标题做为文件名称`:title.md`：

    $ hexo new test-2249
    INFO  Created: e:\workspace\github\blog-github\source\_posts\test-2249.md

如果设为`:year-:month-:day-:title.md` 

    $ hexo new test-2247
    INFO  Created: e:\workspace\github\blog-github\source\_posts\2015-11-07-test-224
    7.md 

两者都自动生成title和date，但是后者更便于管理。    

## 5.2 修改主页
首先对比主页`<foldername>/themes/jekyll/layout/index.jade`:

    extends _partial/layout

    block content
        include _mixin/post
        +homePost()

    block extra
        include _components/project
        include _components/selfintro

和归档页`<foldername>/themes/jekyll/layout/archive.jade`:

    extends _partial/layout

        block content
            include _mixin/post
            +archivePost()
            aside.sidebar
                include _sidebar/tag
                include _sidebar/post            

删掉index.jade中`include _components/project`这句就比较精简了。            
主页样式变成`一篇新文章+个人介绍`，直接修改jekyll/_config.yml下`selfIntro:`部分并不能令人满意，这里直接修改`/layout/_components/selfintro.jade`

    section.selfintro
        .wrap.row-flex.row-flex-row.limit-width
            .sign
                img(src="img/github.png", alt="")
            .intro
                if theme.selfIntro.title
                    h3.title
                        != theme.selfIntro.title
                else 
                    h3.title 超爽der
                if theme.selfIntro.content
                    p.content 
                        != theme.selfIntro.content
                else 
                    p.content 空空
                
                // 默认的href都为空，填上链接
                ul.contact
                    li 
                        a(href="https://github.com/lawlietfans") GitHub
                    li
                        a(href="http://weibo.com/lawlietfans") Weibo

接着再找一个合适的logo替换github.png就可以了（不用也行。。），logo背景透明才能和主题融合


see more: [Jade Syntax Documentatio](http://naltatis.github.io/jade-syntax-docs/)
   
    Comments
    // single line comment
    //- invisible single line comment

## 5.3 修改头部导航    
从这里`/layout/_components/nav.jade`添加修改menu

        nav
            ul.nav-list
                li.nav-list-item
                    a.nav-link(href= theme.menu['home'] class=is_home() ? 'active' : '')
                        = __('index.title')
                li.nav-list-item
                    a.nav-link(href= theme.menu['blog'] class= is_archive() || is_post() ? 'active' : '')    
                        = __('archive.title')
                li.nav-list-item
                    a.nav-link(href= theme.menu['rss'])
                        = __('rss.title')
                //li.nav-list-item
                //    a.nav-link(href= theme.menu['github'] target="_blank")    
                //        = __('github.title')
依个人口味酌情修改即可。除此之外，RSS插件[安装之后][6]本地预览是没效果的，一般部署之后过段时间才有效

## 5.4 侧边栏
`layout/_sidebar/`包含post.jade、tag.jade、和toc.jade三个部件，理论上都可以添加到archive.jade

    extends _partial/layout

    block content
        include _mixin/post
        +archivePost()
        aside.sidebar
            include _sidebar/tag
            include _sidebar/post

但是添加`include _sidebar/toc`之后会报错如下：

    Unhandled rejection TypeError: e:\workspace\github\blog-github\themes\jekyll\lay
    out\_sidebar\toc.jade:1
      > 1| if toc(page.content, {list_number: false})
        2|   h3 文章目录
        3|   != list_tags({amount: 5, show_count: false})
        4|            

有待达人解决

## 5.5 最后如果使用这个主题有兴趣和问题希望到[这里][12]多多交流        

[1]: http://www.ruanyifeng.com/blog/2012/08/blogging_with_jekyll.html "搭建一个免费的，无限流量的Blog----github Pages和Jekyll入门"
[2]: https://pages.github.com/
[3]: http://liuxing.info/2015/06/14/GitHub%E5%8D%9A%E5%AE%A2%E6%90%AD%E5%BB%BA/ "推荐hexo文档"
[4]: https://hexo.io/zh-cn/
[5]: http://liuxing.info/2015/06/14/GitHub%E5%8D%9A%E5%AE%A2%E6%90%AD%E5%BB%BA/#配置Pages "配置pages"
[6]: http://wsgzao.github.io/post/hexo-guide/ "使用GitHub和Hexo搭建免费静态Blog"
[7]: https://hexo.io/themes/ "more themes"
[8]: http://git-scm.com/download/ 
[9]: http://hexo.io/docs/deployment.html
[10]: http://jukezhang.com/2014/11/01/construct-blog-with-hexo&&gitcafe/#安装Jacman主题： "jacman主题"
[11]: http://yangjian.me/workspace/introducing-pacman-theme/ "pacman主题"
[12]: https://github.com/pinggod/hexo-theme-jekyll/issues
