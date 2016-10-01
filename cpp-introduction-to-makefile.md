**Makefile入门**

# 1 手动编译链接

我们知道源文件生成可执行文件的过程可能需要一些依赖文件（头文件或者其他源文件）。[2]中提到对于C语言，产生可执行程序包括这样的步骤：

- 1 预处理源文件（.c）
  - 替换预处理命令（如 #define）
  - 展开头文件（.h，包括静态链接库的头文件）到引用的源文件
- 2 依次编译处理过的源文件，然后进行汇编，生成对应的目标文件（.o）
- 3 链接（静态链接）目标文件和静态链接库（静态链接库的源文件生成的目标文件，.a），生成可执行的二进制文件。


我们假设这里有三个c文件：

hello.c
```c
#include<stdio.h>//sys lib head  file
int main()
{
  int a=33;
  int b=22;
  printf("Min value is %d\n",min(a,b));
  printf("Max value is %d\n",max(a,b));
  return 0;
}
```

max.c
```c
int max(int a,int b)
{
  return a>b?a:b;
}
```

min.c
```c
int min(int a,int b)
{
  return a<b?a:b;
}
```

很明显，hello.c编译必须依赖max.c和min.c。我们手动编译生成可执行文件，并执行：
```sh
fsj@ubuntu:~/templates$ ls
hello.c  max.c  min.c
fsj@ubuntu:~/templates$ gcc -o hello hello.c max.c min.c 
fsj@ubuntu:~/templates$ ls
hello  hello.c  max.c  min.c
fsj@ubuntu:~/templates$ ./hello 
Min value is 22
Max value is 33
```
源文件不多的时候算麻烦了，那一个大工程中几十上百源文件，依赖关系错综复杂的时候怎么编译？这就要借助make工具了。

# 2 借助make自动编译链接

make是软件开发中常用的工具程序（Utility software），常被用来构建C程序。make通过读取叫做`makefile`或者`Makefile`的文件，来自动化建构软件。make命令编译和链接多个源文件的规则是[3]：

- 1）如果这个工程没有编译过，那么我们的所有C文件都要编译并被链接。
- 2）如果这个工程的某几个C文件被修改，那么我们只编译被修改的C文件，并链接目标程序。
- 3）如果这个工程的头文件被改变了，那么我们需要编译引用了这几个头文件的C文件，并链接目标程序。

make工具通过源文件的修改时间来知道哪个源文件被修改了，需要重新编译。

Makefile的规则。

```sh
target ... : prerequisites ...
        command
        ...
        ...
```

target也就是一个目标文件，可以是Object File，也可以是执行文件。还可以是一个标签（Label），对于标签这种特性，在后续的“伪目标”章节中会有叙述[3]。

prerequisites就是，要生成那个target所需要的文件或是目标。

command也就是make需要执行的命令。（任意的Shell命令）

这是一个文件的依赖关系，也就是说，target这一个或多个的目标文件依赖于prerequisites中的文件，其生成规则定义在command中。说白一点就是说，prerequisites中如果有一个以上的文件比target文件要新的话，command所定义的命令就会被执行。这就是Makefile的规则。也就是Makefile中最核心的内容。

还是以上面hello.c为例，makefile可以这样写：
```sh
# this is  make file line comment
hello:max.o min.o hello.c
  gcc max.o min.o hello.c -o hello
max.o:max.c
  gcc -c max.c
min.o:min.c
  gcc -c min.c
```

在定义好依赖关系后，后续的那一行定义了如何生成目标文件的操作系统命令，一定要以一个Tab键作为开头。记住，make并不管命令是怎么工作的，他只管执行所定义的命令。make会比较targets文件和prerequisites文件的修改日期，如果prerequisites文件的日期要比targets文件的日期要新，或者target不存在的话，那么，make就会执行后续定义的命令[3]。

只需要在该目录下输入`make`命令即可运行：
```sh
fsj@ubuntu:~/templates/makeeg$ make
gcc -c max.c
gcc -c min.c
gcc max.o min.o hello.c -o hello
fsj@ubuntu:~/templates/makeeg$ ls
hello  hello.c  makefile  max.c  max.o  min.c  min.o
fsj@ubuntu:~/templates/makeeg$ ./hello 
Min value is 22
Max value is 33
```

我们可以看到make程序还会输出具体command的执行过程。只需要一个命令，就生成了可执行文件，方便了不少。

那make是如何工作的呢？我们只需要输入make，make工具就会在当前目录下找名字叫“Makefile”或“makefile”的文件。
找到文件中的第一个目标文件（target），这便是最终要生成的文件。

首先查找hello的三个依赖项，对于依赖项中的`.c/.cc./.cpp/.h`等源码文件，不存在就直接报错。
例如修改一下hello.c的后缀：
```sh
fsj@ubuntu:~/templates/makeeg$ make
make: *** No rule to make target `hello.cc', needed by `hello'.  Stop.
```

对于`.o`目标文件，向下递归寻找其依赖项并生成。

直到所有依赖项都准备完毕，开始把下一行的command交给shell去执行。make的工作就做完了，至于你command写的对不对就和make无关了。

## 2.1 默认target一定是第一个target

target和源码之间的依赖好比数据结构中的树，第一个target就是root节点。
如果我们写多个无关target，就相当于多了几个root节点，从第一个root并不依赖其他root，所以make程序根本不会执行到多余的target。
```sh
hello:max.o min.o hello.c
  gcc max.o min.o hello.c -o hello
hello1:max.o min.o hello.c
  gcc max.o min.o hello.c -o hello1
max.o:max.c
  gcc -c max.c
min.o:min.c
  gcc -c min.c
```

make之后可以看到并没有生成hello1。

没有被第一个目标文件直接或间接关联，那么它后面所定义的命令将不会被自动执行，不过，我们可以在make后面加target名字来手动指定默认tareget：`$ make hello1`。

如果你乐意的话写多行command，生成hello1也行。
```sh
hello:max.o min.o hello.c
  gcc max.o min.o hello.c -o hello
  gcc max.o min.o hello.c -o hello1
max.o:max.c
  gcc -c max.c
min.o:min.c
  gcc -c min.c
```

多行command，比如command1和command2先后执行。如果command1报错，command2就不会执行了。
```sh
hello:max.o min.o hello.c
  gccc max.o min.o hello.c -o hello # error command
  gcc max.o min.o hello.c -o hello1
max.o:max.c
  gcc -c max.c
min.o:min.c
  gcc -c min.c
```

可以在error command前面加一个`-`，这样make就会忽略这个错误，继续执行下去。

## 2.2 一行有多个target

```sh
hello:max.o min.o hello.c
  gcc max.o min.o hello.c -o hello
min.o max.o:max.c min.c
  gcc -c max.c
  gcc -c min.c
```

## 2.3 make clean

我们定义clean这个target以此来清除所有的目标文件，以便重编译。
```sh
clean:
  rm *.o hello
```
类似的，手动指定target即可。
```sh
fsj@ubuntu:~/templates/makeeg$ ls
hello  hello.c  makefile  max.c  max.o  min.c  min.o
fsj@ubuntu:~/templates/makeeg$ make clean 
rm *.o hello
fsj@ubuntu:~/templates/makeeg$ ls
hello.c  makefile  max.c  min.c
```

# Summary

- makefile中默认生成哪个目标文件：第一个
- target名字和gcc -o出来的不一样：以实际为准
- 多个target生成哪个：第一个
  - 多条命令生成多个target：可以
    - 某一行报错怎么办：加`-`
- 一行有多个target：可以  

# References

- 1 https://www.gnu.org/software/make/manual/make.html
- 2 [Makefile 入门](http://harttle.com/2014/01/01/makefile.html)
- 3 陈皓. [跟我一起写 Makefile](http://blog.csdn.net/haoel/article/details/2886)
