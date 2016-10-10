插入排序是一种简单直观的排序算法。
序列可以分为有序区和无序区，开始时有序区只有第一个元素，然后每次把无序区中第一个元素插入到有序区中。

当无序区为空时，排序结束。

那如何把元素插入到有序区中呢？

直接插入排序的做法是从后到前逐一比较。总时间复杂度为O(N^2)。

既然是插入到有序区，那我们可以考虑用二分法快速找到应该插入的位置，但是在顺序存储结构中，仍然无法避免插入过程移动元素的开销，所以这种方法总时间复杂度仍然是O(N^2)。

就当复习一下二分吧

>参考[1]二分法排序的原理，算法思想简单描述： 
在插入第i个元素时，对前面的0～i-1元素进行折半，先跟他们 
中间的那个元素比，如果小，则对前半再进行折半，否则对后半 
进行折半，直到left>right，然后再把第i个元素前1位与目标位置之间 
的所有元素后移，再把第i个元素放在目标位置上。


具体代码如下：

```cpp
#include<iostream>
#include <stdio.h>
#include<vector>
using  namespace std;
//函数模版，打印vector中的内容
template <typename T>
void printVector(const vector<T>&v)
{
    if(v.empty())   cout<<endl<<"your vector is empty"<<endl;
    cout<<endl;
    for(int i=0;i<v.size();i++)
    {
        cout<<v[i]<<" ";
    }
    cout<<endl;
}
//1. 直接插入排序
vector<int> insertSort(vector<int> v)
{
    if(v.empty()) return v;
    int t=0;
    int n=v.size()-1;
    for(int i=1;i<=n;i++)
    {
        if(v[i]<v[i-1])
        {
            int t=v[i];
            int j=i-1;
            for(;j>=0 && v[j]>t;j--)    v[j+1]=v[j];
            //j位置不满足条件时，循环跳出。所以t应该插入到j+1处。
            v[j+1]=t;
        }
    }
    return v;
}
//2. 二分法
vector<int> binarySort(vector<int> v)
{
    if(v.empty()) return v;
    int n=v.size()-1;

    for(int i=1;i<=n;i++)
    {
        if(v[i]<v[i-1])
        {
            int t=v[i];
            int left=0;
            int right=i-1;
            int mid=0;
            while(left>=0 && left<=right)
            {
                mid=(left+right)/2;
                //如果有2个以上的相同值，不能保证稳定排序
                if (v[mid]==t){ mid+=1; break;}
                else if(v[mid]<t) {left=mid+1;}
                else {right=mid-1;}
            }
            //mid处就是要插入的位置
            int j=i-1;
            for(;j>=mid;j--) v[j+1]=v[j];
            v[mid]=t; //v[j+1]=t;
        }
    }
    return v;
}

//测试
int main()
{
    int a[]={2,1,6,4,5};
    //int a[]={2,4,6,8,5};
    printVector(binarySort(vector<int>(a,a+5)));
}
```
# References

- 1 [二分法排序C++](http://blog.csdn.net/xufeiayang/article/details/52716602)
