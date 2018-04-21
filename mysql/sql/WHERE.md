```
大于
小于
等于

算数运算 + - * / %    加减乘除取模    
比较操作符号 = ， != (<>)  等于 不等于有两种方法 比较 ， <=> 空值比较  ，>= 大于等于, > 大于, <=小于等于,< 小于
闭区间： BETWEEN min_num AND max_num
列表：IN (element1，element2)    在几个元素内
取值为空: IS NULL 
取值非空：IS NOT NULL
模糊比较：LIKE   
                %  任意长度的任意字符
                _  任意单个字符
RLIKE：
REGEXP: 匹配字符串可以使用正则表达式书写模式；

逻辑操作符
    NOT
    AND
    OR
    XOR  与或  二者相同则为假

GROUP
avg() , max(),， min(),count(),, sum()

ORDER BY  对指定的字段查询结果进行排序
 升序 ASC
 降序 DESC

LIMIT 
别名
```

## 大于

```
MariaDB [hellodb]> SELECT Name,Age FROM students WHERE Age>50;
MariaDB [hellodb]> SELECT Name,Age FROM students WHERE Age+30 >50;

```

## 不等于

```
MariaDB [hellodb]> SELECT Name,Age FROM students WHERE Age !=22;
MariaDB [hellodb]> SELECT Name,Age FROM students WHERE Age <>22;
```

## 列表 in

```
MariaDB [hellodb]> SELECT Name,Age FROM students WHERE Age IN (18,100);
```

## 取值为空 NULL 

```
MariaDB [hellodb]> SELECT Name,ClassID FROM students WHERE ClassID IS NULL; 
```

# GROUP

## 取平均值
```
MariaDB [hellodb]> SELECT AVG(Age),Gender FROM students GROUP BY Gender ;
+----------+--------+
| AVG(Age) | Gender |
+----------+--------+
|  19.0000 | F      |
|  33.0000 | M      |
+----------+--------+
2 rows in set (0.00 sec)
```

## 班级人数统计
```
MariaDB [hellodb]> SELECT COUNT(StuID) AS NOS, ClassID FROM students GROUP BY ClassID ;
```

## 人数大于2

```
MariaDB [hellodb]> SELECT COUNT(StuID) AS NOS, ClassID FROM students GROUP BY ClassID HAVING NOS>2;
```

# ORDER BY 升序

```
MariaDB [hellodb]> SELECT COUNT(StuID) AS NOS, ClassID FROM students GROUP BY ClassID HAVING NOS>2 ORDER BY NOS;
+-----+---------+
| NOS | ClassID |
+-----+---------+
|   3 |       7 |
|   3 |       2 |
|   4 |       3 |
|   4 |       6 |
|   4 |       1 |
|   4 |       4 |
```

根据年龄排序

```
MariaDB [hellodb]> SELECT Name , Age FROM students ORDER BY Age LIMIT 10;
+--------------+-----+
| Name         | Age |
+--------------+-----+
| Lin Daiyu    |  17 |
| Xue Baochai  |  18 |
```

降序

```
MariaDB [hellodb]> SELECT Name , Age FROM students ORDER BY Age DESC  LIMIT 10;
+--------------+-----+
| Name         | Age |
+--------------+-----+
| Sun Dasheng  | 100 |
| Xie Yanke    |  53 |
| Shi Qing     |  46 |
```


LIMIT
偏移过去10个取10个
取11到20的值

```
MariaDB [hellodb]> SELECT Name , Age FROM students ORDER BY Age DESC  LIMIT 10,10;
+---------------+-----+
| Name          | Age |
+---------------+-----+
| Yuan Chengzhi |  23 |
| Huang Yueying |  22 |
| Shi Zhongyu   |  22 |
```
