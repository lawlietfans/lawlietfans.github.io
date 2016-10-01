**动态规划及其在LCS问题和01背包问题中的应用**

适合动态规划（DP，dynamic programming）方法的最优化问题有两个要素：最优子结构和重叠子问题。

最优子结构指的是最优解包含的子问题的解也是最优的。

重叠子问题指的是每次产生的子问题并不总是新问题，有些子问题会被重复计算多次。

所以可以用如下步骤来解决：
1. 递归定义最优解计算公式
2. 构造dp表格，按照公式逐步计算。

最简单的例子就是计算斐波那契亚数列第i个值。

# 1 最长公共子序列LCS

[问题定义](http://www.nowcoder.com/questionTerminal/c996bbb77dd447d681ec6907ccfb488a)

对于两个字符串，请设计一个高效算法，求他们的最长公共子序列的长度，这里的最长公共子序列定义为有两个序列U1,U2,U3...Un和V1,V2,V3...Vn,其中Ui&ltUi+1，Vi&ltVi+1。且A[Ui] == B[Vi]。
给定两个字符串A和B，同时给定两个串的长度n和m，请返回最长公共子序列的长度。保证两串长度均小于等于300。

测试样例：
"1A2C3D4B56",10,"B1D23CA45B6A",12
返回：6

假设d(i,j)表示字符串A[0:i]与B[0:j]的最长公共子序列。

- 1 递归公式：`d(i,j) = `
	- 0 //i=0 or j=0
	- d(i-1,j-1)+1	//A[i]=B[j]
	- max( d(i-1,j) , d(i,j-1) )	//A[i]!=B[j]

- 2 列表计算

占位


```cpp

```

# 2 背包问题

[1]中问题定义：话说有一哥们去森林里玩发现了一堆宝石，他数了数，一共有n个。 但他身上能装宝石的就只有一个背包，背包的容量为C。这哥们把n个宝石排成一排并编上号： 0,1,2,…,n-1。第i个宝石对应的价值和重量分别为V[i]和W[i] 。排好后这哥们开始思考： 背包总共也就只能装下体积为C的东西，那我要装下哪些宝石才能让我获得最大的利益呢？


背包问题分为01背包问题和部分背包问题，区别在于物品是否不可分割。

这里的物品不能分割，讨论的是01背包问题。

假设有1,2,3...n一共n个物品。其中v[i]表示第i个物品价值。w[i]表示第i个物品重量。

d(i,j)表示，要把前i个物品放入背包，背包容量为j

- 1 递归公式：`d(i,j)=`
	- 0	//i is 0
	- max( d(i-1,j) , d(i-1,j-w[i])+v[i] )	//j>=w[i] and i>0


- 2 列表计算

占位


```cpp
#include<iostream>
#include <stdio.h>
#include<vector>
//#include"fsjtools.h"
using  namespace std;
int main()
{
    int n,c;//number,cap
    while(cin>>n>>c)
    {
        vector<int> w(n+1,0);//weight
        vector<int> v(n+1,0);//value
        for(int i=1;i<=n;i++) cin>>w[i]>>v[i];//start from 1
        //printVector(w);
        //printVector(v);
        vector<vector<int> > dp(n+1,vector<int>(c+1,0));//初始化为0
        for(int i=1;i<=n;i++)
        {
            for(int j=0;j<=c;j++)
            {
                if(j>=w[i]) dp[i][j]=max(dp[i-1][j],dp[i-1][j-w[i]] + v[i]);
								else dp[i][j]=dp[i-1][j];
            }
        }
        cout<<dp[n][c]<<endl;
    }
}
```


```sh
样例输入

5 10
4 9
3 6
5 1
2 4
5 1

4 9
4 20
3 6
4 20
2 4

5 10
2 6
2 3
6 5
5 4
4 6

样例输出

19
40
15
```

# References

- 1 [动态规划之背包问题（一）](http://www.hawstein.com/posts/dp-knapsack.html)

