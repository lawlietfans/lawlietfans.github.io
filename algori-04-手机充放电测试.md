---
layout: post
title: 手机充放电测试
date: 2017-05-13 12:00:00
comments: true
external-url:
categories: [dfs]
---

# 问题描述

手机电量有上限和下限，超出就会损坏。给定多组充电放电测试，计算每一台手机的最小可能的初始电量值。

每一组测试由充电和放电两个操作组成，假设原电量为a，充电x1，那么电量为a+x1。再放电x2，那么此时手机电量为a+x1-x2

要完成多组测试，没有固定顺序。

**输入**

第一行，需要测试的手机手机数量M。

之后每三行为一台手机的数据，一共M*3行，分别是：

第一行：N（手机需要测试的组数， 1<=N<=8 ），K（手机允许的最大充电量，50<=K<=200)

第二行：对应N组测试的充电电量；

第三行：对应N组测试的放电电量；


**输出**

计算每一台手机的最小可能的初始电量值。

如果不能完成测试，输出-1；

样例输入
```c
3
3 100
75 45 80
30 55 95
2 100
65 90
20 30
5 150
35 105 100 45 75
115 75 55 35 105
```
样例输出
```c
#1 15
#2 -1
#3 25
```

# 讨论

容易的一个正向思路是，对N组测试全排列，可是不知道初始电量，又要考虑测试的全排列，变量太多。


反过来，最大充电量K是确定的，我们可以在[0,K]之间逐个试探，先把初始电量确定下来。然后比较所有可能的测试顺序。

元素全排列的问题可以用DFS来做

# 实现

```cpp

#include<iostream>
using namespace std;
#define debug
#define MAXN 9
#define MAXK 201
int N,K;
int ein[MAXN];
int eout[MAXN];
int visited[MAXN];
int res[MAXN];
int e_min;//start min elec
int e_x;
bool has_res;//has result

inline void input()
{
    cin>>N>>K;
    e_min=0;
    for(int i=0;i<N;i++)
    {
        cin>>ein[i];  // 充电
        e_min+=ein[i];
    }
    for(int i=0;i<N;i++) cin>>eout[i]; // 放电
}
void dfs(int depth, int e)
{
    if(depth>N || e>e_min || e<0 || e>K) return; // 对树剪枝： e>=e_min
 
    if(depth==N)
    {
        if(e_min>e_x) 
        {
          e_min=e_x;      
        }
        has_res=true;
        return;
    }
 
    for(int i=0;i<N;i++)
    {
        if(visited[i]) continue;
        if(e+ein[i]>K) continue;
        if(e+ein[i]-eout[i]<0) continue;
 
        visited[i]=true;  
        res[depth]=i;
        dfs(depth+1, e+ein[i]-eout[i]);
        visited[i]=false;
    }
}
int main()
{
#ifdef debug
    freopen("D:\\data.txt","r",stdin);
#endif
    int test;
    cin>>test;
    for(int t=1;t<=test;t++)
    {
        input();
        has_res=false;
        for(int e=0;e<=K;e++)
        {
            e_x=e;
            dfs(0,e);
        }
    if(has_res==false) e_min=-1;
        cout<<"#"<<t<<" "<<e_min<<endl;
    }
     
    return 0;
}
```
