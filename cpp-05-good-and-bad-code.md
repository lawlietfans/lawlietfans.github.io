烂代码和好代码

问题描述[1]

有一个矩形的房间里铺满正方形瓷砖。每块瓷砖涂成黑色或红色。一个人站在黑色的瓷砖上，从此出发，可以移动到四个相邻的瓷砖之一，但只能移动到黑色的瓷砖上。计算他通过重复上述移动所能经过的黑砖数。

这里把红色改成了白色，其他不变。思路原作者描述的很详细了。
```c
/* 样例输入输出
6 9  //列数、行数
BBBBWB
BBBBBW
BBBBBB
BBBBBB
BBBBBB
BBBBBB
BBBBBB
W@BBBW
BWBBWB
45

0 0 //结束标志
*/
```
这里对比一下我的实现（烂代码）和原作者的实现（好代码）

```cc
#include<iostream>
#include<cstdio>
#include<string>
#include<vector>
using namespace std;
int g=0;
vector<vector<bool> > isvisit;
/*1. 由于每次输入的是字符串，考虑用vector<string>表示该二维矩阵，cin>>str输入每行。
用char a[][]；cin>>a[i] 更方便*/
void reach(vector<string>&v,int x,int y,int h,int w)
{

    if(isvisit[x][y] || v[x][y]=='W') return;

    g++;
    isvisit[x][y]=true;

    //cout<<x<<" "<<y<<" "<<g<<" "<<v[x][y]<<endl;
		/*2. 探索函数，顺序为左右上下
		把所有边界条件写到函数入口更好更方便。*/
    //left
    if(y>0 ) reach(v,x,y-1,h,w);
    //right
    if(y<w-1 ) reach(v,x,y+1,h,w);
    //up
    if(x<h-1) reach(v,x+1,y,h,w);
    //down
    if(x>0 ) reach(v,x-1,y,h,w);
}
int main()
{
    int w,h;//width height//列数、行数
    while(cin>>w>>h)
    {
        if(w==0 && h==0) break;
        vector<string> v(h,"");//1. 初始化矩阵v
        // true: visited
				//初始化二维vector
        isvisit=vector<vector<bool> >(h,vector<bool>(w,false));
        int sx=0;
        int sy=0;
        bool isfindat=false;
        for(int i=0;i<h;i++)
        {
            cin>>v[i];
            if(isfindat==false)
            {
                for(int j=0;j<v[i].size();j++)
                {
                    if(v[i][j]=='@')
                    {
                        sx=i;
                        sy=j;
                        isfindat=true;
                    }
                }
            }
        }

        g=0;
        reach(v,sx,sy,h,w);
        cout<<g<<endl;
    }
}
*/
```

```cc
#include <iostream>
#include<cstring>
using namespace std;
// R 红砖 B 黑砖 @人
const int MAX_ROW = 20, MAX_COLUMN = 20;
int sum, m, n;    //经过的瓷砖数    行数    列数
char map[MAX_ROW][MAX_COLUMN];
bool visited[MAX_ROW][MAX_COLUMN]; //记录访问标志的数组

//递归计算从（row,col）出发经过的瓷砖数
void search(int row, int col)
{
    //边界条件 坐标在地图外，不可通行，已经访问过 则回溯
		// 擦作者这里col>=n写错了，坑死了
    if (row < 0 || row >= n || col < 0 || col >= m || map[row][col] == 'W' || visited[row][col])
    return;

		//cout<<row<<" "<<col<<" "<<sum<<endl;
    visited[row][col] = true; //设置当前坐标的标志位
    ++sum; //经过的瓷砖数+1
    //递归遍历当前坐标的四个相邻点
    search(row , col-1);
    search(row, col+1);
    search(row-1, col);
    search(row+1 , col);
}

int main(){
    while (cin >> m >> n) //输入列数和行数
    {
        if(m==0 && n==0) break;
        int row, col;
        for (int i = 0; i < n; i++)
        {
            cin>> map[i]; //输入当前行的数据集
            for (int j = 0; j < m; j++)
            {
                if (map[i][j] == '@')
                {
                    row = i;
                    col = j;
                }
            }
        }
        //cout<<row<<" "<<col<<endl;
        memset(visited,false,sizeof(visited));
        sum = 0;
        search(row, col);
        cout << sum << endl;
    }
    return 0;
}
```

# References

1. [递归回溯法实战（一）——（Red and Black）红黑砖迷阵（POJ1979）](http://blog.csdn.net/a253664942/article/details/45420987)

