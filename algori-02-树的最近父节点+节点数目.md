---
layout: post
title: 找最近公共祖先，并求该祖先节点的所有子节点数目
date: 2017-05-13 12:00:00
comments: true
external-url:
categories: [DFS]
---

# 问题描述

找最近公共祖先，并求该祖先节点的所有子节点数目。这个问题是下面两个问题的简单叠加：

1. 给定树中两个节点a和b，找出a、b的最近公共祖先。
2. 给定树中某节点，计算该节点分支的成员数量。


**输入**

第一行给定不同的树的个数T，

接下来一行给出成员总数量 V (3 <= V <= 10000),E 边(父母孩子关系)的数量,以及两个给定的成员A,B

下一行给出 E条边(父母孩子关系), 每条边包含两个成员, 总是前面为父母 后面为孩子

根（root）节点总是用1表示, 并且每个节点的号码标记在1~v之间, 但可以大号码是小号码的父亲结点.

**输出**

输出T行，每行以#tc开头，tc代表测试用例编号，接空格，然后输出最靠近的共同祖先X以及此祖先分支的成员数量NX。


样例输入
```c
2
13 12 8 13
1 2 1 3 2 4 3 5 3 6 4 7 7 12 5 9 5 8 6 11 6 10 11 13
10 9 2 10
1 2 1 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10
```
样例输出
```c
#1 3 8
#2 1 10
```


# 讨论

首先考虑数据存储，尽量用简单的结构将树存储起来。

每个节点的号码标记在1~v之间。可以考虑用S[]和D[]两个数组分别存储每条边的起点和终点，S[i]和D[i]分别为第i条边的起点和终点。以样例输入1为例，树的逻辑结构如图1所示，对应的两个数组如图2所示，这样就把E条边存储起来了。
【图】

有了这两个数组，任给一个节点作为终点，然后将其对应的起点作为新终点，就可以一路找到根节点（也就是值为1的节点）。

任给两条路径的情况下，只需遍历一下就可以得到两个节点的的最早公共                                                点。如图3所示

类似的，任给一个节点作为起点，然后将其对应的所有终点作为新起点，就可以遍历得到所有子节点。当然也能算出所有子节点的数目。

# 实现

```cpp
#include <iostream>
using namespace std;
#define debug
#define max_node 10001 // start from 1
int v;
int e;
int v_a;
int v_b;
int S[max_node-1];//source
int D[max_node-1];//dest
int link_va[max_node];
int link_vb[max_node];
void input()
{
  cin>>v>>e>>v_a>>v_b;
  int index=0;
  for (int i=0;i<e;i++)
  {
    cin>>S[index]>>D[index]; //S大致有序，有可能有乱的
#ifdef debug 
    cout<<S[index]<<","<<D[index]<<" ";
#endif
    index++;    
  }
#ifdef debug 
  cout<<endl;
#endif
}

void find_link(int vertex, int link[]) //找到节点vertex到根节点的路径
{
  int t=vertex;
  int index=0;
  while(t)
  {
    link[index]=t;
    index++;
    if (t==1) break;
    
    for (int i=0;i<e;i++)
    {
      if (D[i]==t)
      {
        t=S[i];
        break;
      }
    }
  }
}
int findpr()//find commom parent of va,vb
{
  find_link(v_a,link_va);
  find_link(v_b,link_vb);
  for (int i=0;i<max_node && link_va[i]>0;i++)
  {
    for (int j=0;j<max_node && link_vb[j]>0;j++)
    {
      if (link_va[i]==link_vb[j])
      {
        return link_va[i];
      }
    }
  }
}
int ElemNum(int v_id)
{
  int res=1;
  for (int i=0;i<e;i++)
  {
    if (v_id==S[i])   res+=ElemNum(D[i]);
  }
  return res;
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
    input();
    int vid=findpr();
    cout<<"#"<<i<<" "<<vid<<" "<<ElemNum(vid)<<endl;
  }
  return 0;
}
```
