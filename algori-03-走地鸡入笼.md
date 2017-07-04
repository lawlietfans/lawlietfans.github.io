---
layout: post
title: 走地鸡入笼问题
date: 2017-05-13 12:00:00
comments: true
external-url:
categories: []
---

# 问题描述

给定一排鸡笼（可看作一维数组），编号为0-N。

已知：

1. 一个鸡笼只能放一只鸡
2. 有三个入口，分别对应三个鸡笼。从入口到自己对应的鸡笼距离为1，每经过一个鸡笼距离加1
3. 每个入口外面都有一群鸡排队，鸡要进入距离入口最近的鸡笼。
4. 从入口到左右空鸡笼距离相等的情况下，去哪个都行
5. 三个入口有序进入。一个入口进完之后才轮到下一个
6. 鸡笼一定放得下所有鸡

要求所有鸡入笼距离之和的最小值。

**输入**

鸡场会给出每一个门对应的鸡笼的位置和每个门进笼的走地鸡数量。

第一行测试用例数量。

接下来每四行是一个测试用例数据：

该四行的第一行是鸡笼数量N（5<=N<=60），
接下来三行每一行是两个数字，
第一个代表鸡场门对应的鸡笼编号i，
第二个代表从该门进入的鸡群数量c（1<=c<=20）。

**输出**

输出每个case的最短的入笼距离。

样例输入
```c
5
10
4 5
6 2
10 2
10
8 5
9 1
10 2
24
15 3
20 4
23 7
39
17 8
30 5
31 9
60
57 12
31 19
38 16
```
样例输出
```c
#1 18
#2 25
#3 57
#4 86
#5 339
```


# 讨论

三个入口的进入顺序就是全排列的所有情况。都要考虑。

然后分析一个入口的情况：

对于第一个入口而言，鸡笼全空，假如鸡群为奇数，那么入笼的结果只有一种最优结果，必然是关于入口轴对称的。

假如鸡群是偶数，那么最后一只鸡是放左侧还是右侧呢？放左侧可称为左优先策略，放右侧可称为右优先策略。

前者的入笼结果会对接下来的入笼情况造成影响。所以需要分别讨论前两个入口的策略情况。

# 实现

```cpp
#include <iostream>
using namespace std;
#define debug
#define n_max 61
int lst[n_max]; // 表示n_max个笼子
// 三个入口的下标、等待进去的鸡的数目
int g_pos[3];//gate pos
int g_c[3];//gate count
int n;//len of lst
int ans;

inline void input()
{
  cin>>n;
  for (int i=0;i<3;i++)
  {
    cin>>g_pos[i]>>g_c[i];
  }
}

inline int leftin(int gindex)
{
  int count=g_c[gindex]; // 当前入口，还在排队的鸡的数量
  int k=g_pos[gindex]; // 当前入口，在lst的下标
  int j=1,t;
  int res=0;
  //先左后右依次入笼，左右各进去一个为一批
  //由当前为第j批，推算出应该入笼的左侧下标和右侧下标
  while(count)
  {
    t=k-j+1;//左侧下标
    if (t>=1 && lst[t]==0)//不越界，可放
    {
      lst[t]=j;
      res+=j;
      count--;
    }
    if(count==0) break;
    t=k+j-1;//右侧下标
    if (t<=n && lst[t]==0)
    {
      lst[t]=j;
      res+=j;
      count--;
    }
    j++;
  }
  return res; //本入口的鸡全部进去了
}

inline int rightin(int gindex)//先右后左
{
  int count=g_c[gindex];
  int k=g_pos[gindex];
  int j=1,t;
  int res=0;
  while(count)
  {
    t=k+j-1;
    if (t<=n && lst[t]==0)
    {
      lst[t]=j;
      res+=j;
      count--;
    }
    if(count==0) break;
    t=k-j+1;
    if (t>=1 && lst[t]==0)
    {
      lst[t]=j;
      res+=j;
      count--;
    }   
    j++;
  }
  return res;
}


inline void check(int a,int b,int c)
{
  // 无论具体什么顺序，a、b、c表示第1、2、3个开始入笼的入口
  // a和b的入笼方法会对第三个造成影响，第三个随意入笼  
  int t=0;
  for(int i=1;i<=n;i++) lst[i]=0; //clear
  t=leftin(a)+leftin(b)+rightin(c); // a和b共四种情况
  ans=ans<t?ans:t;
  for(int i=1;i<=n;i++) lst[i]=0;
  t=leftin(a)+rightin(b)+rightin(c);
  ans=ans<t?ans:t;
  for(int i=1;i<=n;i++) lst[i]=0;
  t=rightin(a)+leftin(b)+rightin(c);
  ans=ans<t?ans:t;
  for(int i=1;i<=n;i++) lst[i]=0;
  t=rightin(a)+rightin(b)+rightin(c);
  ans=ans<t?ans:t;
}

int main()
{
#ifdef debug
  freopen("D:\\data.txt","r",stdin);
#endif
  int test;
  cin>>test;
  for (int i=1;i<=test;i++)
  {
    input() ;
    ans=9999;
    check(0,1,2); check(0,2,1); // 三个入口的全排列
    check(1,0,2); check(1,2,0);
    check(2,0,1); check(2,1,0);
    cout<<"#"<<i<<" "<<ans<<endl;
  }
  return 0;
}
```
