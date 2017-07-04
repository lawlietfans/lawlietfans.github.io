---
layout: post
title: 一条路线有多少走法
date: 2017-06-21 12:00:00
comments: true
external-url:
categories: [dfs]
---

# 问题描述

用N乘N的二维矩阵表示一个完整街区。如果格子值为0，表示可通过。值为9表示不可通过。
给定街区中M个目标格子，值分别为1, 2, 3, ..., M-1，从1处开始，按次序穿过所有目标格子，一共有多少走法？

**输入**

第一行为测试组数t，之后为t组。

样例输入
```c
5
5 4    
1 0 0 0 0
0 0 0 0 0
0 2 0 4 0
9 0 0 9 0
0 0 0 3 0
3 3  
1 0 0
0 2 9 
0 9 3
6 5 
0 0 0 0 0 9
0 0 0 0 9 0
0 0 0 5 0 0
3 9 9 0 0 9
2 0 0 0 0 0
1 0 0 0 0 4
7 2
0 0 0 0 0 0 0
0 9 9 9 9 9 0
0 0 0 0 0 9 0
0 9 9 0 0 9 0
0 9 0 0 2 9 0
0 9 9 9 9 9 0
0 0 0 0 0 0 1
7 5  
1 3 0 0 0 0 0 
9 0 0 0 0 0 0
0 0 5 0 0 0 0 
0 0 0 9 0 0 0
0 0 0 0 0 0 0 
0 0 0 0 0 0 4
0 0 0 0 0 0 2
```

# 讨论

简化问题，如果街区中只有两个目标格子，那么从起点到终点也容易用dfs实现。多个目标格子的话就是重复上述过程。

# 实现

```cpp
#include <iostream>
using namespace std;
#define max_n 7
#define max_m 5
int grid[max_n][max_n];
int n;
int m;
int X[max_m+1];//0,1,2,...m
int Y[max_m+1];
int endx;
int endy;
int minpathlen;
int minpathways;

void input()
{
  cin>>n>>m;
  for(int i=0;i<n;++i)
  {
    for (int j=0;j<n;j++)
    {
      cin>>grid[i][j];
    }
  }
}

void findpoint()//fill xy[1,m]
{ 
  for (int i=0;i<n;i++)
  {
    for (int j=0;j<n;j++)
    {
      if(grid[i][j]>=1 && grid[i][j]<=m)
      {
        int k=grid[i][j];
        X[k]=i;
        Y[k]=j;
      }
    }
  }
}

void dfs(int level, int sx, int sy)
{
  if(level>minpathlen || sx<0 || sx>n-1 || sy<0 || sy>n-1 || grid[sx][sy]==9) return;

  if(sx==endx && sy==endy)
  {
    if (level<minpathlen)
    {
      minpathlen=level;
      minpathways=1;
    }else if (level==minpathlen)
    {
      minpathways++;
    }
  }else
  {
    grid[sx][sy]=9;//每个点四种选择，必须要防止踩回原来的点
    dfs(level+1,sx+1,sy);
    dfs(level+1,sx-1,sy);
    dfs(level+1,sx,sy+1);
    dfs(level+1,sx,sy-1);
    grid[sx][sy]=0;
  }
}

int main()
{
#ifdef debug
  freopen("D:\\data.txt","r",stdin);
#endif
  int test;
  cin>>test;
  for (int ti=1;ti<=test;ti++)
  {
#ifdef debug
    cout<<ti<<":"<<endl;
#endif    
    input();
    findpoint();
    long res=1;
    for (int i=2;i<=m;i++)
    {
      endx=X[i];
      endy=Y[i];
      minpathlen=n*n*n;
      minpathways=0;
      dfs(0,X[i-1],Y[i-1]);
      
      res*=minpathways;
      if(res==0) break;
    }
    
    cout<<"#"<<ti<<" "<<res<<endl;
  }
  return 0;
}
```
