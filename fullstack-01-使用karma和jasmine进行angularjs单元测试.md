---
layout: post
title: 使用karma和jasmine进行angularjs单元测试
date: 2017-11-10 12:00:00
comments: true
external-url:
categories: [测试]
---

JavaScript是一门脚本语言，并不包含编译器，所以无法保证类型安全。

单元测试可以弥补编译器的缺乏，找出潜在的缺陷。

# 1 Jasmine测试框架

[Jasmine](https://jasmine.github.io/)是一种测试框架，定义了测试用例的语法、API、如何编写断言等等。类似的产品还包括Mocha等。

```sh
call browser-visit-direct.html  # windows
open browser-visit-direct.html  # osx
```
或者直接用浏览器打开browser-visit-direct.html:

```html
```

可以看到

![failures](http://images2017.cnblogs.com/blog/631533/201711/631533-20171111085513169-701885927.png)

![Spec list](http://images2017.cnblogs.com/blog/631533/201711/631533-20171111085601903-528162481.png)

其中，测试中的首句`describe`可以理解为包含多个测试样例的容器。

`it`是单元测试的核心代码，我们在it块内调用函数，检查返回值是否符合预期。每个`expect`语句都接受一个参数，根据内置的匹配函数或者自定义匹配函数进行判断。

常用的Jasmine匹配函数包括：
1. toEqual
2. toBe
3. toBeTruthy
4. toBeFalsy

……

# 2 Karma安装和配置

1、install nodejs： https://nodejs.org/en/

2、淘宝cnpm：https://npm.taobao.org/

查看全局安装的模块：`cnpm list -g`

3、安装karma

```sh
$ cnpm install -g karma-cli # 为了能在命令行直接执行 karma 命令
$ mkdir ex03 & cd ex03
$ cnpm install karma --save-dev  # 自动生成package.json
$ cnpm install karma-jasmine karma-chrome-launcher --save-dev
$ cat package.json                    
{                                     
  "devDependencies": {                
    "karma": "^1.7.1",                
    "karma-chrome-launcher": "^2.2.0",
    "karma-jasmine": "^1.1.0"         
  }                                   
}     

$ karma init # 交互式自动生成karma.conf.js
```

# 3 单元测试

## 3.1 编写

```js
// File: ex03/controller.js                                           
angular.module('notesApp', [])                                            
  .controller('ListCtrl', [function() {                                   
                                                                          
    var self = this;                                                      
    self.items = [                                                        
      {id: 1, label: 'First', done: true},                                
      {id: 2, label: 'Second', done: false}                               
    ];                                                                    
                                                                          
    self.getDoneClass = function(item) {                                  
      return {                                                            
        finished: item.done,                                              
        unfinished: !item.done                                            
      };                                                                  
    };                                                                    
}]);                                                                      
// File: ex03/controllerSpec.js                                       
describe('Controller: ListCtrl', function() {                             
  // Instantiate a new version of my module before each test              
  beforeEach(module('notesApp'));                                         
                                                                          
  var ctrl;                                                               
                                                                          
  // Before each unit test, instantiate a new instance                    
  // of the controller                                                    
  beforeEach(inject(function($controller) {                               
    ctrl = $controller('ListCtrl');                                       
  }));                                                                    
                                                                          
  it('should have items available on load', function() {                  
    expect(ctrl.items).toEqual([                                          
      {id: 1, label: 'First', done: true},                                
      {id: 2, label: 'Second', done: false}                               
    ]);                                                                   
  });                                                                     
                                                                          
  it('should have highlight items based on state', function() {           
    var item = {id: 1, label: 'First', done: true};                       
                                                                          
    var actualClass = ctrl.getDoneClass(item);                            
    expect(actualClass.finished).toBeTruthy();                            
    expect(actualClass.unfinished).toBeFalsy();                           
                                                                          
    item.done = false;                                                    
    actualClass = ctrl.getDoneClass(item);                                
    expect(actualClass.finished).toBeFalsy();                             
    expect(actualClass.unfinished).toBeTruthy();                          
  });                                                                     
                                                                          
});                                                                       
```

`karma.conf.js`中，files包含需要引入的js文件，browser表示要启动的浏览器
```js
    // list of files / patterns to load in the browser
   files: [
      'angular.min.js',
      'angular-mocks.js',
      'controller.js',
      'controllerSpec.js'
    ],
    // Start these browsers, currently available:
    // - Chrome
    // - ChromeCanary
    // - Firefox
    // - Opera
    // - Safari (only Mac)
    // - PhantomJS
    // - IE (only Windows)
    browsers: ['Chrome'],
```

## 3.2 运行

```sh
$ karma start
11 11 2017 10:29:41.138:WARN [karma]: No captured browser, open http://localhost:8080/
11 11 2017 10:29:41.152:INFO [karma]: Karma v1.7.1 server started at http://0.0.0.0:8080/
11 11 2017 10:29:41.153:INFO [launcher]: Launching browser Chrome with unlimited concurrency
11 11 2017 10:29:41.166:INFO [launcher]: Starting browser Chrome
11 11 2017 10:29:43.146:INFO [Chrome 62.0.3202 (Windows 10 0.0.0)]: Connected on socket Yi2gR771fEmcfPqnAAAA with id 31405350
Chrome 62.0.3202 (Windows 10 0.0.0): Executed 2 of 2 SUCCESS (0.032 secs / 0.022 secs)

```

源码：https://github.com/shenjiefeng/js-fortest/tree/master/angularjs/ex04-unittest/

## 3.3 使用PhantomJS
phantomjs是提供一个浏览器环境的命令行接口
```sh
$ cnpm install --save-dev karma-phantomjs-launcher
```

参考官网 https://www.npmjs.com/package/karma-phantomjs-launcher ，修改karma.conf.js

运行
```sh
$ karma start --browsers PhantomJS_custom
11 11 2017 11:10:29.055:WARN [karma]: No captured browser, open http://localhost:8080/
11 11 2017 11:10:29.071:INFO [karma]: Karma v1.7.1 server started at http://0.0.0.0:8080/
11 11 2017 11:10:29.071:INFO [launcher]: Launching browser PhantomJS_custom with unlimited concurrency
11 11 2017 11:10:29.086:INFO [launcher]: Starting browser PhantomJS
11 11 2017 11:10:29.133:INFO [phantomjs.launcher]: ACTION REQUIRED:
11 11 2017 11:10:29.133:INFO [phantomjs.launcher]:
11 11 2017 11:10:29.133:INFO [phantomjs.launcher]:   Launch browser at
11 11 2017 11:10:29.133:INFO [phantomjs.launcher]:   http://localhost:9000/webkit/inspector/inspector.html?page=2
11 11 2017 11:10:29.133:INFO [phantomjs.launcher]:
11 11 2017 11:10:29.133:INFO [phantomjs.launcher]: Waiting 15 seconds ...
11 11 2017 11:10:47.356:INFO [PhantomJS 2.1.1 (Windows 8 0.0.0)]: Connected on socket gYJpL9b4Ax1vcSXRAAAA with id 54603354
PhantomJS 2.1.1 (Windows 8 0.0.0): Executed 2 of 2 SUCCESS (0 secs / 0.017 secs)
```


## 3.4 代码覆盖率

代码覆盖率常常被拿来作为衡量测试好坏的指标
```sh
cnpm install karma karma-coverage --save-dev
```
参照官网 https://www.npmjs.com/package/karma-coverage 修改`karma.conf.js`

```js
    // coverage settings
    // coverage reporter generates the coverage
    reporters: ['progress', 'coverage'],

    preprocessors: {
      // source files, that you wanna generate coverage for
      // do not include tests or libraries
      // (these files will be instrumented by Istanbul)
      'src/**/*.js': ['coverage']
    },

    // optionally, configure the reporter
    coverageReporter: {
      type : 'html',
      dir : 'coverage/'
    },
    // end coverage settings done
```

运行
```sh
λ karma start                                                                           
11 11 2017 15:44:39.502:WARN [karma]: No captured browser, open http://localhost:8080/  
11 11 2017 15:44:39.502:INFO [karma]: Karma v1.7.1 server started at http://0.0.0.0:8080
/                                                                                       
11 11 2017 15:44:39.518:INFO [launcher]: Launching browsers PhantomJS, PhantomJS_custom 
with unlimited concurrency                                                              
11 11 2017 15:44:39.518:INFO [launcher]: Starting browser PhantomJS                     
11 11 2017 15:44:39.565:INFO [launcher]: Starting browser PhantomJS                     
11 11 2017 15:44:39.580:INFO [phantomjs.launcher]: ACTION REQUIRED:                     
11 11 2017 15:44:39.580:INFO [phantomjs.launcher]:                                      
11 11 2017 15:44:39.580:INFO [phantomjs.launcher]:   Launch browser at                  
11 11 2017 15:44:39.580:INFO [phantomjs.launcher]:   http://localhost:9000/webkit/inspec
tor/inspector.html?page=2                                                               
11 11 2017 15:44:39.580:INFO [phantomjs.launcher]:                                      
11 11 2017 15:44:39.580:INFO [phantomjs.launcher]: Waiting 15 seconds ...               
11 11 2017 15:44:42.665:INFO [PhantomJS 2.1.1 (Windows 8 0.0.0)]: Connected on socket tR
S1I1S_vRFKRXcwAAAA with id 93001704                                                     
11 11 2017 15:44:57.665:INFO [PhantomJS 2.1.1 (Windows 8 0.0.0)]: Connected on socket dk
GUuJAC80MqA_98AAAB with id 67337991                                                     
PhantomJS 2.1.1 (Windows 8 0.0.0): Executed 2 of 2 SUCCESS (0.016 secs / 0.01 secs)     
PhantomJS 2.1.1 (Windows 8 0.0.0): Executed 2 of 2 SUCCESS (0 secs / 0.012 secs)        
TOTAL: 4 SUCCESS                                                                        
```

查看生成的代码覆盖率
```sh
$ ls "coverage\PhantomJS 2.1.1 (Windows 8 0.0.0)\
base.css  index.html  prettify.css  prettify.js  sort-arrow-sprite.png  sorter.js
```

![100 code coverage](http://images2017.cnblogs.com/blog/631533/201711/631533-20171111155505075-1491548630.png)

# 4 在测试中注入html，访问DOM元素

## 4.1 将html写入到js中

源码：https://github.com/shenjiefeng/js-fortest/tree/master/angularjs/ex02-karma-tutorial

## 4.2 从外部html文件导入

将html写入到js中太麻烦了，可不可以用[karma-fixture](https://github.com/billtrik/karma-fixture)来实现导入呢

```sh
 karma start
11 11 2017 16:12:49.337:WARN [karma]: No captured browser, open http://localhost:9876/
11 11 2017 16:12:49.353:INFO [karma]: Karma v1.7.1 server started at http://0.0.0.0:9876/
11 11 2017 16:12:49.353:INFO [launcher]: Launching browsers PhantomJS, PhantomJS_custom with unlimited concurrency
11 11 2017 16:12:49.368:INFO [launcher]: Starting browser PhantomJS
11 11 2017 16:12:49.399:INFO [launcher]: Starting browser PhantomJS
11 11 2017 16:12:49.415:INFO [phantomjs.launcher]: ACTION REQUIRED:
11 11 2017 16:12:49.415:INFO [phantomjs.launcher]:
11 11 2017 16:12:49.415:INFO [phantomjs.launcher]:   Launch browser at
11 11 2017 16:12:49.415:INFO [phantomjs.launcher]:   http://localhost:9000/webkit/inspector/inspector.html?page=2
11 11 2017 16:12:49.415:INFO [phantomjs.launcher]:
11 11 2017 16:12:49.415:INFO [phantomjs.launcher]: Waiting 15 seconds ...
11 11 2017 16:12:52.545:INFO [PhantomJS 2.1.1 (Windows 8 0.0.0)]: Connected on socket ddCmyvggaUdxkr1rAAAA with id 6133081
11 11 2017 16:13:07.557:INFO [PhantomJS 2.1.1 (Windows 8 0.0.0)]: Connected on socket C670QlbDCLLzPfHYAAAB with id 60711068
LOG: Fixture{base: 'test', id: 'fixture_container', json: [], scriptTypes: Object{application/ecmascript: 1, application/javascript: 1, application/x-ecmascript: 1, application/x-javascript: 1, text/ecmascript: 1, text/javascript: 1, text/javascript1.0: 1, text/javascript1.1: 1, text/javascript1.2: 1, text/javascript1.3: 1, text/javascript1.4: 1, text/javascript1.5: 1, text/jscript: 1, text/livescript: 1, text/x-ecmascript: 1, text/x-javascript: 1}, el: <div id="fixture_container"></div>}
PhantomJS 2.1.1 (Windows 8 0.0.0) Calculator should return 3 for 1 + 2 FAILED
        ReferenceError: Cannot find fixture 'test/hello.html' in node_modules/_karma-fixture@0.2.6@karma-fixture/lib/fixture.js (line 141)
        _throwNoFixture@node_modules/_karma-fixture@0.2.6@karma-fixture/lib/fixture.js:141:77
        load@node_modules/_karma-fixture@0.2.6@karma-fixture/lib/fixture.js:78:33
        test/calculator.test.js:49:24
        executeFiltered@node_modules/_karma-jasmine@0.2.3@karma-jasmine/lib/boot.js:126:18
        node_modules/_karma-jasmine@0.2.3@karma-jasmine/lib/adapter.js:171:31
        loaded@http://localhost:9876/context.js:162:17
        global code@http://localhost:9876/context.html:48:28
        TypeError: null is not an object (evaluating 'document.getElementById('x').value = 1') in test/calculator.test.js (line 60)
        test/calculator.test.js:60:33
        executeFiltered@node_modules/_karma-jasmine@0.2.3@karma-jasmine/lib/boot.js:126:18
        node_modules/_karma-jasmine@0.2.3@karma-jasmine/lib/adapter.js:171:31
        loaded@http://localhost:9876/context.js:162:17
        global code@http://localhost:9876/context.html:48:28
```

对应的代码覆盖率：

![error code coverage](http://images2017.cnblogs.com/blog/631533/201711/631533-20171111160412950-32595550.png)

![error code coverage](http://images2017.cnblogs.com/blog/631533/201711/631533-20171111160516278-1553251967.png)
可以看出，9句中4句未覆盖。

如何解决`ReferenceError: Cannot find fixture 'test/hello.html'`问题呢？

几经尝试，还是同样的问题，忧桑啊。

# 参考

1. 《AngularJS即学即用》
1. https://npmjs.org/browse/keyword/karma-launcher
1. https://segmentfault.com/a/1190000005708178
1. [Karma Tutorial - Unit Testing JavaScript](http://www.bradoncode.com/blog/2015/02/27/karma-tutorial/)
