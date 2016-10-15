
编译器处理虚函数的方法是：给每个对象添加一个隐藏成员——虚函数表（virtual function table，vtbl）[1]。

毫无疑问，下面的代码会用函数指针读取并调用虚函数表指向的每个函数。

```cpp
#include<iostream>
using  namespace std;
class A
{
public:
    virtual void g(){cout<<"A g()"<<endl;}
    virtual void f(){cout<<"A f()"<<endl;}
};
class B:public A
{
public:
    void g(){cout<<"B g()"<<endl;}
    virtual h(){cout<<"B h()"<<endl;}
};
typedef void (*Fun)(void);
int main()
{
    B b;
    for(int i=0;i<3;i++)
    {
        Fun pf=(Fun)*( (int*)*(int*)(&b) +i);
        pf();
    }
}
/*output
B g()
A f()
B h()
*/
```

但是`Fun pf=(Fun)*( (int*)*(int*)(&b) +i);`究竟是什么意思呢？

b是类B的实例，`(int*)(&b)`表示把b在内存中的地址强制转换为`(int*)`，取得虚函数表的地址。

`*(int*)(&b)`表示虚函数表中第一个的地址元素，该地址指向b的第一个成员函数。

将其强制转为`(int*)`后，i为偏移量。我们可以看到i为0、1、2时对应调用的分别是`B::g() / A::f() / B::h()`。




发现[2]中的例子和这里的例子意思完全一样:
```cpp
class Base {
     public:
            virtual void f() { cout << "Base::f" << endl; }
            virtual void g() { cout << "Base::g" << endl; }
            virtual void h() { cout << "Base::h" << endl; }
};
typedef void(*Fun)(void);
int main()
{ 
            Base b;
            Fun pFun = NULL;
            cout << "虚函数表地址：" << (int*)(&b) << endl;
            cout << "虚函数表 — 第一个函数地址：" << (int*)*(int*)(&b) << endl;
 
            // Invoke the first virtual function 
            pFun = (Fun)*((int*)*(int*)(&b));
            pFun();
}
```
加偏移量调用其他成员函数
```cc
(Fun)*((int*)*(int*)(&b)+0);  // Base::f()
(Fun)*((int*)*(int*)(&b)+1);  // Base::g()
(Fun)*((int*)*(int*)(&b)+2);  // Base::h()
```

b的对象模型中包含一个虚函数指针vptr，该指针指向其虚函数表vtbl

在派生过程中，子类覆盖父类虚函数的过程就是替换vtbl中该函数地址的过程。

![](http://pic002.cnblogs.com/images/2012/370714/2012121621033522.png)


C++的编译器应该是保证虚函数表的指针存在于对象实例中最前面的位置（这是为了保证取到虚函数表的有最高的性能——如果有多层继承或是多重继承的情况下）。 这意味着我们通过对象实例的地址得到这张虚函数表，然后就可以遍历其中函数指针，并调用相应的函数。 [2]

通过b首地址找到虚函数表的地址图示

![](http://pic002.cnblogs.com/images/2012/370714/2012121620213691.jpg)

到这里终于搞清楚了。


附C++对象模型[3]

```cc
class Point{
protected:
    virtual ostream& print(ostream&os)const;
    float _x;
    static int _point_count;
public:
    Point(float xval);
    virtual ~Point();
    float x() const;
    static int PointCount();
};
```

![](http://images.cnblogs.com/cnblogs_com/dubingsky/WindowsLiveWriter/706d6c6463a4_9C26/image_6.png)



# References

1. c++ primer plus sixth edition
2. [查看虚函数表](http://www.cnblogs.com/mhjerry/archive/2012/12/16/2820895.html)
3. [ Inside C++ object Model--对象模型概述](http://blog.csdn.net/fxjtoday/article/details/6080547)
