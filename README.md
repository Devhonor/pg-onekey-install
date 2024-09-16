***
#先决条件(requirements)
配置好yum仓库
Completing configuration of yum repository

***
#使用说明(using manual)
-  当前自动安装脚本适用于红帽家族 8.9 系统，其它版本未做测试，请根据环境自己测试
-  The current auto-install scripts are compatible with Red Hat family OS version 8.9. Other versions have not been verified, so please test it when using on those.

####配置文件(configuration files)
-  配置文件包括两个，一个日志配置文件，一个环境配置文件，日志配置文件不用做任何改动，环境配置文件需要手动配置。
There are two files in the conf folder: one for log configuration and one for environment settings. You do not need to change the log configuration file, but you need to modify the parameter values in the environment file.
***

#使用步骤(using steps)
1. 使用 root 用户上传文件到任意目录
Upload  files to any directory using root user
```bash
[root@server ~]# mkdir -p /opt/software/
[root@server software]# cd pg-onekey-install
[root@server pg-onekey-install]# pwd
/opt/software/pg-onekey-install
[root@server pg-onekey-install]# ls
bin  conf  exec  lib  log  tools
[root@server pg-onekey-install]# 
```
2. 编辑 conf/env.cnf 文件

```
#Define Install Name 
#安装名称
INSTALL_NAME="PostgreSQL Database"  #specifying any string

#Define database package's path
#源码包路径
SOFTWARE_PACKAGE_PATH=/opt/software/postgresql-17rc1.tar.bz2

#Define PG_HOME,which is an install destination for PostgreSQL product
#安装位置
PG_HOME=/usr/local/pgsql

#Define LD_LIBRARY_PATH
#调用库路径
LD_LIBRARY_PATH=${PG_HOME}/lib:${LD_LIBRARY_PATH}
#Define PATH
#执行程序路径
PATH=${PG_HOME}/bin:${PATH} #setting execute file path

#Define data directory,which is a database cluster directory
#数据库集簇路径
PG_DATA=/data2/pgdata

#网卡名称
NIC_NAME=ens160 #specify network interface card name,must be options

#主机名称
HOSTNAME=server  #setting host name

#Define running os user
#运行PostgreSQL Database 的操作系统用户
INSTALL_USER= #if the value is empty,default postgres

#Define superadmin user
#数据库超级管理员用户
SUPERADMIN= #if the value is empty,default postgres

#Define auth method
#数据库认证方式
AUTHMETHOD= #if the value is empty,default trust

#Define database server encode
#数据库服务器编码
SERVERENCODE= #if the value is empty,default utf8

#Define page size 
#数据块页面大小(1|2|4|8|16|32)
PAGE_SIZE= #if the value is empty,default 8, the unit is kb

#Define running port
#数据库绑定端口
PGPORT= #if the value is empty,default 5432

```

3. 切换到bin目录执行 sh install.sh 
***注意*** :
- 在第8步的时候需要为运行数据库操作系统用户设置一个密码 (In step 8, you need to set a password for the database running user.)
- 安装用户在conf/env.cnf 中已配置


```bash
[root@server bin]# sh install.sh install
[2024-09-14 PM 16:40:28]  ########################### [PostgreSQL Database] Begin install ########################### 
[2024-09-14 PM 16:40:28]  1. Configuring hostname and dns begin 
[2024-09-14 PM 16:40:29]        hostname configuration successfully! 
[2024-09-14 PM 16:40:29]     Configuring hostname end 
[2024-09-14 PM 16:40:29]  2. Checking firwalld begin 
[2024-09-14 PM 16:40:29]        Firewall has been forbiden !
[2024-09-14 PM 16:40:29]     Checking firwalld end 
[2024-09-14 PM 16:40:29]  3. Checking selinux begin 
[2024-09-14 PM 16:40:29]        Warning: Selinux is active,please disabled it using setenforce 0 
[2024-09-14 PM 16:40:29]     Checking selinux end 
[2024-09-14 PM 16:40:29]  4. Checking user and group begin  
[2024-09-14 PM 16:40:29]         user already exists ! 
[2024-09-14 PM 16:40:29]     Checking user and group end  
[2024-09-14 PM 16:40:29]  5. Checking software dependences and installing loss software begin 
[2024-09-14 PM 16:40:29]        The package libicu-devel has been installed ! 
[2024-09-14 PM 16:40:30]        The package openssl-devel has been installed ! 
[2024-09-14 PM 16:40:30]        The package openldap-devel has been installed ! 
[2024-09-14 PM 16:40:31]        The package zlib-devel has been installed ! 
[2024-09-14 PM 16:40:31]        The package libxslt-devel has been installed ! 
[2024-09-14 PM 16:40:32]        The package libxml2-devel has been installed ! 
[2024-09-14 PM 16:40:32]        The package readline-devel has been installed ! 
[2024-09-14 PM 16:40:33]        The package pam-devel has been installed ! 
[2024-09-14 PM 16:40:33]        The package python3-devel will be installed !
[2024-09-14 PM 16:40:34]        The package python3-devel install successfully 
[2024-09-14 PM 16:40:34]        The package tcl-devel has been installed ! 
[2024-09-14 PM 16:40:35]        The package perl-devel has been installed ! 
[2024-09-14 PM 16:40:35]        The package perl-ExtUtils-Embed has been installed ! 
[2024-09-14 PM 16:40:36]        The package perl-ExtUtils-MakeMaker has been installed ! 
[2024-09-14 PM 16:40:36]        The package lz4-devel has been installed ! 
[2024-09-14 PM 16:40:37]        The package libzstd-devel has been installed ! 
[2024-09-14 PM 16:40:37]        The package systemd-devel has been installed ! 
[2024-09-14 PM 16:40:38]        The package libuuid-devel has been installed ! 
[2024-09-14 PM 16:40:38]        The package libtool will be installed !
[2024-09-14 PM 16:40:39]        The package libtool install successfully 
[2024-09-14 PM 16:40:39]        The package e2fsprogs-devel has been installed ! 
[2024-09-14 PM 16:40:40]        The package e2fsprogs will be installed !
[2024-09-14 PM 16:40:40]        The package e2fsprogs install successfully 
[2024-09-14 PM 16:40:41]        The package e2fsprogs-libs has been installed ! 
[2024-09-14 PM 16:40:41]        The package libselinux-devel has been installed ! 
[2024-09-14 PM 16:40:42]        The package llvm-devel has been installed ! 
[2024-09-14 PM 16:40:42]        The package bc has been installed ! 
[2024-09-14 PM 16:40:42]     Checking software dependences and installing loss software end 
[2024-09-14 PM 16:40:42]  6. Configuring kernel parameters begin 
[2024-09-14 PM 16:40:42]        Kernel parameter configuration completed ! 
[2024-09-14 PM 16:40:42]     Configuring kernel parameters end 
[2024-09-14 PM 16:40:42]  7. Configuring resource limits begin 
[2024-09-14 PM 16:40:42]        Resource limits configuration completed ! 
[2024-09-14 PM 16:40:42]     Configuring resource limits end 
[2024-09-14 PM 16:40:42]  8. Configuration os user begin 
[2024-09-14 PM 16:40:42]        Installation user default: postgres
[2024-09-14 PM 16:40:42]        User postgres exists
[2024-09-14 PM 16:40:42]        Create user postgres and group 
[2024-09-14 PM 16:40:42]        Setting postgres user password
Please input postgres os user's password: postgres
Please confirm postgres os user's password: postgres
[2024-09-14 PM 16:40:46]        Setting postgres user password successfully !
[2024-09-14 PM 16:40:46]     Configuration os user end 
[2024-09-14 PM 16:40:46]  9. Configuration install directory begin 
[2024-09-14 PM 16:40:46]        The data directory already exists
[2024-09-14 PM 16:40:46]     Configuration install directory end 
[2024-09-14 PM 16:40:46]  10.Compiling installation begin 
[2024-09-14 PM 16:43:40]      Compiling installation end 
[2024-09-14 PM 16:43:40]  11.Configuring postgres user environment begin 
[2024-09-14 PM 16:43:41]      Configuring postgres user environment end 
[2024-09-14 PM 16:43:41]  12.Initialize PostgreSQL database cluster begin 
[2024-09-14 PM 16:43:41]      Initialize PostgreSQL database cluster end 
[2024-09-14 PM 16:43:41]  13.Verifying database connection begin 
[2024-09-14 PM 16:43:41]        Connection successfully !
[2024-09-14 PM 16:43:41]     Verifying database connection end 
[2024-09-14 PM 16:43:41]  ########################### [PostgreSQL Database] End install   ########################### 
Running cost time: 192.53 seconds,Sat Sep 14 16:43:41 CST 2024 
```

4. 验证(Verifying)
```
[root@server bin]# su - postgres
Last login: Sat Sep 14 16:43:41 CST 2024 on pts/1
[postgres@server ~]$ psql
psql (17rc1)
Type "help" for help.

```


