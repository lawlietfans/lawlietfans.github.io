[1]中提到，规范的派生类构造函数三个要点：
1. 首先创建基类对象
2. 应通过成员初始化列表，创建基类对象
3. 应该初始化本派生类新增的成员变量

那在构造派生类实例的过程中，其基类（以及多继承的时候多个基类）/当前对象属性/当前对象的构造顺序如何呢？

下面初步分析：

# 1 不显式调用基类构造函数

C继承B1和B2
```cpp
#include<iostream>
using namespace std;
class B1
{
public:
    B1(){ cout<<"B1"<<endl;}
};
class B2
{
public:
    B2(){cout<<"B2"<<endl;}
};
class C:public B1,public B2
{
public:
    C(){cout<<"C"<<endl;}
};
int main()
{
    C obj;
    return 0;
}
/*output
B1
B2
C
*/
```
其中，冒号指出C的基类是B1和B2，public限定符指出B1和B2都是公有基类，我们称之为公有派生[1]。
>公有派生中，基类的公有成员（成员变量、成员方法）变成了派生类的公有成员。基类的私有成员变成了派生类的私有成员，但是不能直接访问，只能借助基类的public和protected方法访问。

这时，程序将使用基类默认构造函数。  
也就是说C的写法相当于在成员初始化列表调用基类的默认构造函数：`C():B1(),B2(){cout<<"C"<<endl;}`。

- B1和B2的构造顺序只和继承的顺序有关，和成员初始化列表中的顺序无关

调整继承顺序`class C:public B2,public B1`，输出顺序为`B2 B1`.而修改成员初始化列表中的顺序没有效果。

# 2 显式调用基类构造函数

同样的，B1和B2的构造顺序只和继承的顺序有关，和成员初始化列表中的顺序无关
```cpp
class B1
{
public:
    B1(){ cout<<"B1"<<endl;}
    B1(int i){ cout<<"B1:"<<i<<endl;}
};
class B2
{
public:
    B2(){cout<<"B2"<<endl;}
    B2(int i){ cout<<"B2:"<<i<<endl;}
};
class C:public B2,public B1
{
public:
    C():B1(10),B2(20){cout<<"C"<<endl;}
};
int main()
{
    C obj;
    return 0;
}
/*output
B2:20
B1:10
C
*/
```
更进一步可以把C中构造函数参数作为实参传递给基类构造函数：
`C(int x,int y):B1(x),B2(y){cout<<"C"<<endl;}`

# 3 封闭类

有成员对象的类称为封闭类，这是对象组合的一种实现方式[2]。

修改C为：
```cpp
class C:public B2,public B1
{
private:
    int x;
    B1 memberb1;
    B2 memberb2;
public:
    C():B1(10),B2(20){cout<<"C"<<endl;}
};
/*output
B2:20
B1:10
B1
B2
C
*/
```

- 构造子类实例过程中，依次进行如下构造：
    - 构造基类
    - 构造当前派生类的成员对象
    - 构造当前派生类（执行自己的构造函数）

## 3.1 对当前对象属性使用成员初始化列表语法

当前对象属性就是`成员对象`。

```cpp
class C:public B2,public B1
{
private:
    int x;
    B1 memberb1;
    B2 memberb2;
public:
    C():B1(10),B2(20),memberb1(1),memberb2(2){cout<<"C"<<endl;}
};
/*output
B2:20
B1:10
B1:1
B2:2
C
*/
```
和基类很相似。

在成员初始化列表，如果不显式调用成员对象的构造函数，程序就会调用默认构造函数。显式调用，程序就会调用你指定的构造函数。

成员对象之间的构造顺序之和声明顺序有关，和在Member Initialization List中的顺序无关。

当然，也可以不指定初始化列表，在构造函数中再进行成员对象的赋值，这会导致成员对象被构造多次。 更重要的是，因为常量类型、引用类型的成员不接受赋值，它们只能在初始化列表中进行初始化。[2]

到这里，基类/当前对象属性/当前对象的构造顺序终于搞清楚了。

# Reference

- 1 C++ primer plus第六版
- 2 [C++手稿：封装与继承](http://harttle.com/2015/06/29/cpp-encapsulation-and-inheritance.html)
