---
layout: post
title: Spring Boot 的数据访问：JPA 和 MyBatis
date: 2017-12-02 12:00:00
comments: true
external-url:
categories: [springboot, database]
---

JPA(Java Persistence API)是一个基于O/R映射(Object-Relational Mapping)的标准规范，主要实现包括Hibernate、EclipseLink和OpenJPA等。

orm框架的本质是简化编程中操作数据库的编码[2]，JPA 方便程序员不写sql语句，而 MyBatis 呢，则适合灵活调试动态sql。
本文梳理了springboot整合jpa和mybatis的大体过程，并给出了两个demo。

# 1 在docker环境下运行数据库

首先安装vmware虚拟机，然后安装docker。
在docker中 pull Oracle镜像并启动容器。
最后把虚拟机的1521端口映射到宿主机上。


- 数据库：Oracle XE 11g
- 宿主机数据库客户端：SQL developer

```c

注意必须先禁用/etc/selinux/config中selinux选项，然后重启系统。否则安装好的oracle没有默认实例  
[root@localhost fsj]# docker pull wnameless/oracle-xe-11g

查看已经安装的镜像
[root@localhost fsj]# docker images 

启动容器
[root@localhost fsj]# docker run -d -p 9091:8080 -p 1521:1521 --name xe wnameless/oracle-xe-11g
9bf0a03006471a2268b239c32bed00737ee94ef93f92650226c056b0fb891b40
[root@localhost fsj]# netstat -nlp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      948/sshd            
tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      1051/master         
tcp6       0      0 :::1521                 :::*                    LISTEN      5403/docker-proxy-c 
tcp6       0      0 :::22                   :::*                    LISTEN      948/sshd            
tcp6       0      0 ::1:25                  :::*                    LISTEN      1051/master         
tcp6       0      0 :::9091                 :::*                    LISTEN      5396/docker-proxy-c 
udp        0      0 0.0.0.0:68              0.0.0.0:*                           767/dhclient        
udp        0      0 0.0.0.0:47439           0.0.0.0:*                           767/dhclient        
udp6       0      0 :::17787                :::*                                767/dhclient        
raw6       0      0 :::58                   :::*                    7           646/NetworkManager


[root@localhost fsj]# docker ps -a
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS                      PORTS                                                    NAMES
2865df7bf94a        wnameless/oracle-xe-11g   "/bin/sh -c '/usr/sbi"   5 seconds ago       Up 2 seconds                22/tcp, 0.0.0.0:1521->1521/tcp, 0.0.0.0:9091->8080/tcp   xe

进入容器的shell: docker exec -it container-id/container-name bash
[root@localhost fsj]# docker exec -it xe bash 

然后以system/oracle登陆。
$ sqlplus system/oracle
```


表空间

```sh
创建
SQL> create tablespace ts_fsj
    datafile '/u01/app/oracle/oradata/XE/ts_fsj.dbf'
    size 50m
    autoextend on
    maxsize 10g;

查看表空间
SQL>  select name from v$datafile
SQL> select file_name,tablespace_name from dba_data_files;
```

新建用户

```sh
create user boot
  identified by boot
  default tablespace ts_fsj
  temporary tablespace temp
  profile default

grant connect,resource,dba to boot
```


# 2 springboot整合jpa

新建maven项目：
```sh
mvn archetype:generate \
  -DgroupId=com.fsj \
  -DartifactId=ex01 \
  -DarchetypeArtifactId=maven-archetype-quickstart \
  -DinteractiveMode=false
```
[具体代码](https://github.com/shenjiefeng/springboot-examples/tree/master/ex01-jpa)

要建立数据访问DAO层，需要定义一个继承了JpaRepository的接口。然后编写查询方法，例如

```java
public interface PersonRepository extends JpaRepository<Person, Long> {
    // 通过Address相等查询，参数为address
    List<Person> findByAddress(String address);

    Person findByNameAndAddress(String name, String address);

    @Query("select p from Person p where p.name= :name and p.address= :address")
    Person withNameAndAddressQuery(@Param("name") String name, @Param("address") String address);

    // 对应Person实体中的 @NameQuery
    Person withNameAndAddressNamedQuery(String name, String address);
}
```

简单的查询方法包括：

1、通过属性名查询

使用了findBy、Like、And等关键字命名方法，那么就不需要编写具体的sql了，比如

通过Address相等查询，参数为address，可以写成`List<Person> findByAddress(String address);`

相当于JPQL： `select p from Person p where p.address=?1`

完整的查询关键字见：[Spring Data JPA 查询方法支持的关键字](https://www.cnblogs.com/BenWong/p/3890012.html)

2、使用@Query注解

3、使用@NameQuery注解

支持用JPA的NameQuery来定义查询方法，一个名称映射一个查询语句

dao层写好之后就可以在controller层直接调用了。


# 3 springboot整合mybatis

[具体代码](https://github.com/shenjiefeng/springboot-examples/tree/master/ex02-mybatis)

1、新建maven项目

2、修改pom文件，添加依赖包

3、修改application.properties 添加相关配置

4、在数据库中添加测试用city表和数据

```sql
CREATE TABLE city (
    id VARCHAR2(32) NOT NULL ,
    name VARCHAR2(64),
    state VARCHAR2(64),
    country VARCHAR2(64),
    PRIMARY KEY(ID)
);

INSERT INTO city (id, name, state, country) VALUES ('1', 'San Francisco', 'CA', 'US');
INSERT INTO city (id, name, state, country) VALUES ('2', 'Beijing', 'BJ', 'CN');
INSERT INTO city (id, name, state, country) VALUES ('3', 'Guangzhou', 'GD', 'CN');
COMMIT ;
```

5、开发Mapper。使用注解和xml两种方式

```java
public interface CityMapper {

    @Select("SELECT id, name, state, country FROM city WHERE state = #{state}")
    City queryByState(String state);

    @Select("select * from city")
    List<City> queryAll();

    //xml方式，适合复杂查询
    List<City> fuzzyQuery(@Param("name") String name);
}
```
对应的CityMapper.xml
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >
<mapper namespace="com.fsj.dao.CityMapper">
    <sql id="Base_Column_List">
        id, name, state, country
    </sql>
    <resultMap id="BaseResultMap" type="com.fsj.entity.City">
        <result column="id" property="id"/>
        <result column="name" property="name"/>
        <result column="state" property="state"/>
        <result column="country" property="country"/>
    </resultMap>

    <select id="fuzzyQuery" resultMap="BaseResultMap">
        SELECT * FROM CITY
        WHERE 1>0
        <if test="name != null and name != '' ">
            <bind name="fuzzyname" value=" '%'+name+'%' "/>
            AND UPPER(name) like #{fuzzyname, jdbcType=VARCHAR}
        </if>
    </select>
</mapper>
```

6、添加测试

```java
@RunWith(SpringRunner.class)
@SpringBootTest
//@Transactional
public class CityTest {
    private MockMvc mvc1;
    private MockMvc mvc2;
    private String url_get_all;

    @Autowired
    CityMapper cityMapper;

    @Autowired
    WebApplicationContext webApplicationContext;

    @Before
    public void setUp() throws Exception {
        mvc1 = MockMvcBuilders.standaloneSetup(new CityController()).build();
        mvc2 = MockMvcBuilders.webAppContextSetup(webApplicationContext).build();
        url_get_all = "/mybatis/queryAll";
    }

    @Test
    public void testQueryAll() throws Exception {
        List<City> expected = cityMapper.queryAll();
        List<City> actual = cityMapper.queryAll();
        Assert.assertEquals("queryAll测试失败", JSON.toJSONString(expected), JSON.toJSONString(actual));
    }

    /**
     * 验证controller是否正常响应并打印返回结果
     * http://www.ityouknow.com/springboot/2017/05/09/springboot-deploy.html
     * 此处MockMvc对象请求失败，可能只适用于springboot1.3.6旧版本
     * @throws Exception
     */
    @Test
    public void testRequest() throws Exception {
        mvc1.perform(MockMvcRequestBuilders.get(url_get_all).accept(MediaType.APPLICATION_JSON))
                .andExpect(MockMvcResultMatchers.status().isOk())
                .andDo(MockMvcResultHandlers.print())
                .andReturn();

    /*output
    * org.springframework.web.util.NestedServletException: Request processing failed; nested exception is java.lang.NullPointerException
*/
    }

    @Test
    public void testRequest2() throws Exception {
        MvcResult res = mvc2.perform(MockMvcRequestBuilders.get(url_get_all).accept(MediaType.APPLICATION_JSON))
                .andReturn();
        int status = res.getResponse().getStatus();
        String content = res.getResponse().getContentAsString();
        List<City> expected = cityMapper.queryAll();

        Assert.assertEquals(200, status);
        Assert.assertEquals(JSON.toJSONString(expected), content);//json元素顺序不同，测试不过

        /*json对象比较，在python中自动排序，对象比较为True
         Expected :[{"country":"US","id":"1","name":"San Francisco","state":"CA"},{"country":"CN","id":"2","name":"Beijing","state":"BJ"},{"country":"CN","id":"3","name":"Guangzhou","state":"GD"}]
         Actual   :[{"id":"1","name":"San Francisco","state":"CA","country":"US"},{"id":"2","name":"Beijing","state":"BJ","country":"CN"},{"id":"3","name":"Guangzhou","state":"GD","country":"CN"}]
         * */
    }
}
```

# References

1. 汪云飞. 《spring boot实战》
2. http://www.cnblogs.com/ityouknow/p/6037431.html
3. https://github.com/mybatis/spring-boot-starter/wiki/Quick-Start
4. https://www.bysocket.com/?p=1610
