---
layout: post
title: 合并单元格
date: 2017-11-05 12:00:00
comments: true
external-url:
categories: []
---

# 问题描述

输出报表的项目中有一个需求是把多级菜单输出到excel中。比如菜单“5”下面包含子菜单“1”和“2”。子菜单下面又有菜单。一共三级。

我们很容易把菜单数据直接输出，如图(a)所示。
合并冗余项之后如图(b)所示。

![](http://images2017.cnblogs.com/blog/631533/201711/631533-20171105190736045-694450442.png)

具体如何合并菜单呢？

已经有函数可以把给定区域序号之间的单元格合并。合并之后新单元格的值是区域最左上角元素的值。

# 讨论

容易看出只需要合并同一行的相同元素，不用考虑跨列的合并。

问题可以转换成：给定一个序列以及起止下标，给出该范围内所有可以合并的子序列起止下标。

三级菜单已经分割完毕，不需要处理。
一级菜单遍历一遍可以在O(1)的复杂度内给出结果。
假设起止下标为(left,right)，我们用mid指针遍历这个序列，当mid与left所指的值不同时就意味着得到一个子序列（left,mid-1）。遍历结束后可以得到所有结果

![](http://images2017.cnblogs.com/blog/631533/201711/631533-20171105192140154-1726559401.png)
为了方便处理最后一段子序列，mid需要遍历到right+1位置才能结束。我们可以给right+1列添加一个BORDER值，标记结束。


要注意二级菜单的分割范围受到了一级菜单的影响，即不能越界：

![](http://images2017.cnblogs.com/blog/631533/201711/631533-20171105192918513-923870964.png)
这样是错的。

所以可以利用上一步的结果，得到最终的合并方案。

# 实现

```java
import javafx.util.Pair;

import java.util.ArrayList;
import java.util.Arrays;

public class Main {

    private static ArrayList<Pair<Integer, Integer>> GetSpan(ArrayList<String> line,
                                                             ArrayList<Pair<Integer, Integer>> borders) {
        ArrayList<Pair<Integer, Integer>> res = new ArrayList<>();

        for (Pair<Integer, Integer> p : borders) {
            Integer left = p.getKey();
            Integer right = p.getValue() + 1;
            for (int mid = left; mid <= right; mid++) {
                if (!line.get(mid).equals(line.get(left))) {
                    if (mid - 1 > left) {
                        res.add(new Pair<>(left, mid - 1));
                    }
                    left = mid;
                }
            }
            if (left.equals(p.getKey())) {
                res.add(new Pair<>(left, right - 1));
            }
        }
        return res;
    }

    public static void main(String[] args) {

//        String[] t={"0","1","2","3","5","5","6","6","7","7","|"}; // eg1
        String[] t = {"0", "1", "2", "3", "1", "1", "1", "1", "1", "1", "|"}; // eg2
        ArrayList<String> line = new ArrayList<String>(Arrays.asList(t));
//        System.out.println(line);

        ArrayList<Pair<Integer, Integer>> border = new ArrayList<>();
//        border.add(new Pair<Integer, Integer>(4,9)); // eg1
        border.add(new Pair<>(4, 5)); // eg2
        border.add(new Pair<>(6, 7));
        border.add(new Pair<>(8, 9));

        System.out.println(GetSpan(line, border));
    }
}

```
