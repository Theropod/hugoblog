---
title: "CWIC-Beijing服务器软件安装与操作记录"
date: 2021-06-21T17:54:31+08:00
draft: false
categories:
- WEB相关
- GIS
tags:
- 毕业用
---
## 背景
需要为CWIC的Opensearch系统提供数据，并使其最终能在NASA Earth Data Search上找到。对于CEOS，以NRSCC节点的名义来发布GLASSGLASS数据。目前已经把目录中的名称在IDN网站上注册

------
## 文件和存储位置
### GLASS数据
1. BNU这次新送来的硬盘里，有新产生的XML文件和图象文件
2. 同时XML文件已经在/root/glass-xml, 有Albedo、BBE、DSR、ET、FAPAR、FV、GPP、LAI、PAR九个文件夹
- 修改后向CWIC注册的GLASS数据集：24个
    ```
    NRSCC_GLASS_Albedo_AVHRR_0.05D
    NRSCC_GLASS_Albedo_MODIS_0.05D
    NRSCC_GLASS_Albedo_MODIS_1KM
    NRSCC_GLASS_BBE_AVHRR_0.05D
    NRSCC_GLASS_BBE_MODIS_0.05D
    NRSCC_GLASS_BBE_MODIS_1KM
    NRSCC_GLASS_ET_AVHRR_0.05D
    NRSCC_GLASS_ET_MODIS_0.05D
    NRSCC_GLASS_ET_MODIS_1KM
    NRSCC_GLASS_FAPAR_AVHRR_0.05D
    NRSCC_GLASS_FAPAR_MODIS_0.05D
    NRSCC_GLASS_FAPAR_MODIS_1KM
    NRSCC_GLASS_FVC_AVHRR_0.05D
    NRSCC_GLASS_FVC_MODIS_500M
    NRSCC_GLASS_FVC_MODIS_0.05D
    NRSCC_GLASS_GPP_AVHRR_0.05D
    NRSCC_GLASS_GPP_MODIS_500M
    NRSCC_GLASS_GPP_AVHRR_0.05D_YEARLY
    NRSCC_GLASS_GPP_MODIS_500M_YEARLY
    NRSCC_GLASS_LAI_AVHRR_0.05D
    NRSCC_GLASS_LAI_MODIS_0.05D
    NRSCC_GLASS_LAI_MODIS_1KM
    NRSCC_GLASS_DSR_MODIS_0.05D
    NRSCC_GLASS_PAR_MODIS_0.05D
    ```
### 张衡数据
- 数据  
原始的放在/data/upload
解压后和生成xml的脚本放在/data/for_download
- 数据下载配置  
安装了httpd让人下载数据   
配置根据https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-centos-8  
数据（通过软链接）和log放在/var/www/CSES/  
配置文件在/etc/httpd/sites-available和/etc/httpd/sites-enabled

### 其他文件
- Onenote有张衡数据的一些说明
- 本地有张衡数据的文件说明、GLASS和张衡数据Collection列表、访问测试结果
- 本地备份了服务器上用的一些脚本
- Github里有pycsw的版本，服务器上用的一些脚本

## Opensearch和Pycsw软件操作
### 安装
- /root/pycsw下从git安装了pycsw
    - 用稳定版，目前是2.6.0 尝试过几次开发中的版本都有返回结果出错的问题
    - 安装方式是官网上的deploy in 4 minutes
    - 以screen运行了pycsw的http服务
- 安装了一个httpd，用来让别人访问我的OSDD
    - pycsw站点的设置文件在/etc/httpd/sites-available和sites-enabled
    - OSDD 放在/var/www/pycsw

### 标准和数据
- ceos有opensearch best practice的文档，但没有pycsw的教程。为了将数据集发布到NASA里面并可以搜索到，数据集级别的搜索需要在注册页面提供OSDD文档url，能够选择collection和通过kvp来时空搜索
- 数据已经被转成了ISO19115 xml格式
- 坐标问题：pycsw需要XML有ReferenceSystemInfo这一项，若缺失就都填入CARTESIAN，否则无法通过pycsw。DSR和PAR数据集有此问题。
- 需要修改元数据XML中的ParentIdentifier作为数据集名称
- 具体的执行脚本在/root/glass-xml/prepare_xml.sh
```bash
# 示例命令
find . -type f -exec sed -i '63s#<gco:CharacterString></gco:CharacterString>#<gco:CharacterString>CARTESIAN</gco:CharacterString>#g' {} \;
find . -type f -name "*AVHRR*" -exec sed -i '13i \  \<gmd:parentIdentifier>\n    <gco:CharacterString>NRSCC_GLASS_Albedo_AVHRR_0.05D</gco:CharacterString>\n  </gmd:parentIdentifier>' {} \;
# find condition -exec COMMANDS {} \; 是一个固定用法，find的结果被放在{}里面一个个执行，-exec和\;之间的东西是commands)
```

### 数据入库
- 更换数据库为postgis，原来是sqlite，性能低
- postgis安装初始化教程
https://people.planetpostgresql.org/devrim/index.php?/archives/107-Installing-PostGIS-3.1-and-PostgreSQL-13-on-CentOS-8.html
https://computingforgeeks.com/how-to-install-postgis-on-centos-8-linux/  
查看安装状态`systemctl status postgresql-13`
- 现在的安装  
```bash
# 安装后设置username和passwd，填给pycsw的default.cfg
pip install psycopg2-binary #安装postgis
create database pycsw, table records, pycsw-admin.py -c setup_db -f default.cfg # 准备好pycsw使用的数据库
```
- 导入时提示`SAWarning: Did not recognize type 'geometry' of column 'wkb_geometry'`但据这个说不影响。https://gitter.im/geopython/pycsw?at=5f96914a270d004bcfef308d
- 所有的入库命令在文件存储位置和Github处有备份
```bash
# 示例命令
cd /root/pycsw
. bin/activate
cd /root/pycsw/pycsw
pycsw-admin.py -c load_records -f default.cfg -p /root/glass-xml/Albedo
# 这个命令不会Recursively导入数据
```

### OSDD准备
- 要把OSDD(OpenSearch Descriptor Document)放在/var/www/pycsw/glass/osdd，用apache服务出去，它描述了本机所有数据集的opensearch地址。
- OSDD修改自pycsw默认的OSDD，做了模板文件和生成osdd的脚本，放在/var/www/pycsw和Github

### 运行
#### 使用httpd来发布osdd文件
- 安装httpd，把osdd的xml放入/var/www/pycsw/glass/osdd
https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-centos-8  
地址如`http://47.90.244.40/glass/osdd/par.xml`
#### httpd的配置
- NASA解析要求我们不要出现端口号，同时在看log时发现对httpd和本地的pycsw都有很多无关请求。因此
服务器关闭了所有非httpd的端口，把不并使用Virtualhost proxypass来转发pycsw的本地端口到/csw，用rewriteCond把所有不想要的请求都返回404。同时设置了log
- pycsw.conf配置文件
```
LoadModule rewrite_module modules/mod_rewrite.so
<VirtualHost *:80>
    ServerName pycsw
    ServerAlias pycsw
    DocumentRoot /var/www/pycsw
    ErrorLog /var/www/pycsw/log/error.log
    CustomLog /var/www/pycsw/log/requests.log combined

    ProxyPass "/csw" "http://127.0.0.1:8000"
    ProxyPassReverse "/csw" "http://127.0.0.1:8000"

    RewriteEngine On
    RewriteCond %{REQUEST_URI} !^\/csw.*$
    RewriteCond %{REQUEST_URI} !^\/glass.*$
    RewriteCond %{REQUEST_URI} !^\/zhangheng.*$
    # RewriteRule Pattern Substitution [Flags]
    # ^ the begining of path
    # - do not substitute
    # response 404 and stop rewriting immediately
    RewriteRule ^ - [R=404,L]
</VirtualHost>
```
#### pycsw里default.cfg
- 关于端口设置  
如果用wsgi.py的话，默认就是localhost:8000 在config里面改的端口是pycsw用来给外面描述的（应该写成被apache重定向之后的那个），比如在opensearch的atom返回里面就记录了这个返回xml的URL，URL里面的ip和port就是在config里面改的
- 关于log  
pycsw的log等级我定成了DEBUG，文本较多，希望使用logrotate来管理。logrotate的log目录不能是所有人读写的，因此放在/var/log/pycsw，并且给root新建了一个组pycsw用来处理log。  
/etc/logrotate.d/pycsw的内容为：
```
/var/log/pycsw.log{
monthly
minsize 10M
create 0664 root pycsw
rotate 3
missingok
notifempty
dateext
}
```
#### 确保运行
- 发现这个pycsw的wsgi会谜之停止，log上看不出是怎么回事，因此设置了一个脚本放到cron里来检查/csw有没有返回，若没有的话就杀死，然后新开一个screen来跑pycsw。
```sh
#!/bin/sh
res=$( curl -w %{http_code} -s --output /dev/null http://localhost:8000/csw)
if [ $res -ne 200 ]
then
    echo "Error $res on $1"
    # kill existed and start
    if screen -list | grep -q "pycsw"; then
       screen -S pycsw -X quit
    fi
    # startnew
    screen -S pycsw -dm bash -c '. /root/pycsw/bin/activate; python /root/pycsw/pycsw-2.6.0/pycsw/wsgi.py'
fi
```

### pycsw输出opensearch结果的流程
- 发送GET请求，版本为csw2.0.2，请求为getRecords，方式为opensearch
- server.py 导入outputSchemas，根据请求设置iface为csw2类并导入KVP parameters，调用csw2的getRecords方法获得符合outputschema的结果，调用response_csw2opensearch得到符合opensearch的返回结果
- csw2.py 实现getRecords，根据输入parameters的不同以不同方式生成<ogc:filter>xml形式的constraints，再转为对数据库的查询语句，使用repository.py的query.all()方法得到结果。得到结果后，调用outputSchema目录中atom.py的write_record方法返回查询到的多条记录
- 这个query本来是sqlalchemy.session.query定义的类，在repository.py中继承，加了一些方法（如何从kvp解析的条件组装出来类）。它的all方法可以执行查询，返回list。在repository.py里面有LOG指明了查询开始的地方
- atom.py 实现write_record方法，把查询到的按照pycsw md_core_model组织的记录转换为本schema定义的xml形式 （atom:entry atom:category atom:id等）
- opensearch.py 实现response_csw2opensearch的_csw2_2_os给csw得到的返回记录们加上opensearch要求的头部（atom:feed atom:id atom:title os:totalResults os:startIndex os:itemsPerPage）
- pycsw/core/config.py有pycsw的md_core_model  etc/mappings.py里是md_core_model和数据库的对应。

### 对pycsw的修改
#### 给返回结果加上dc:date和rel=encolsure
(CWIC Opensearch Best Practice中推荐，对方要求有这个日期值。给rel=enclosure是为了让NASA知道这个是下载链接)
- 在2.6.0版本的pycsw/pycsw/plugins/outputschemas/atom.py加入

```python
val1 = util.getqattr(result, context.md_core_model['mappings']['pycsw:TempExtent_begin'])
val2 = util.getqattr(result, context.md_core_model['mappings']['pycsw:TempExtent_end'])
date = '/'
if val1:
    date = val1 + date
if val2:
    date = date + val2
if (date != '/'):
    etree.SubElement(node, util.nspath_eval('dc:date', context.namespaces)).text = date
```

#### 通过CQL或者FILTERXML来搜索数据集
- 上面已经提到了pycsw搜索数据集的流程。如果根据Opensearch的q=collection_id这种方法来限定查询的数据集，速度慢。这是因为q是根据数据库记录全文向量化之后的结果来查询，没有索引。
- 实验：在csw2.py修改了kvp constraints里面的where语句，直接指定records.parentIdentifire=identifier，发现可以加快速度。这是因为此constraints用于定义repository.py中的query实例。
- pycsw的GET请求kvp里面可以设置constraints，以达到过滤的目的，但是文档里没有说怎么加。看代码和测试和issues找到了CQL和Filter XML两种方式，其中CQL方式更方便。由于查询条件是xml中的值，&<>都不能出现，官方的例子是全都URLEncode过之后的结果见https://github.com/geopython/pycsw/blob/master/tests/functionaltests/suites/default/get/requests.txt
- 使用q和CQL两种方式的具体测试结果在我的本地文件 Tsinghua\组务\2020元数据csw\GLASS-CSW\GLASS-OSDD.xlsx里面有记录

#### 同时使用Filter和KVP
- pycsw2.6.0无法同时处理CQL/XML Filter（此处用来指定Collection）和KVP Constraints（用来指定时间空间），同时输入这两种条件会出现忽略或报错的情况。但显然指定Collection的Opensearch需要同时输入这两种条件，因此要修改csw2.py
- pycsw2.8.0可以在kvp里指定parentIdentifier，但同时使用Filter和KVP的问题不知道有没有解决。
- csw2.py本来关于Filter的处理逻辑：
    1. self.parent.kvp['constraintlanguage']有两种：CQL和Filter
    2. self.parent.kvp['constraint']用来放具体constraint内容
    3. 若检测到kvp中有OpenSearch Geo/Time Extension规定的key（`self.parent.kvp['bbox/time/q']`, 在2.8.0版本中应该有更多？），就设置constraintlanguage为Filter，将此kvp转为xml并作为constraint的内容
    4. 若没有检测到上面的几种key，就根据constraintlanguage的类型分别获取到xml,再转为数据库查询
- 修改后的处理逻辑：
    1. 检测到OpenSearch Geo/Time Extension规定的key时先判断是否有CQL/XML Constraints已经被定义。
    2. 若有，就把这几个key转为xml filter，CQL/XML Constraints转为<ogc:Filter>，二者合并。
    3. 若没有，设置constraintlanguage为Filter，将此kvp转为xml并作为constraint的内容（和原来一样）
- 修改已经放到了Github的版本里
#### 处理Optional Template Parameters
- Optional template parameters就是key=?这种，如果没有值可用的话， 搜索客户端就把空值放到?里。CEOS测试数据集时用了这个，需要我们不报错。
- 在csw2.py中加入判断，kvp中检测到了key但value为空，不要处理，也不要抛出异常终止响应
- 相应修改已经放到了Github的版本里


### 如何查询
- gmd:parentId设置成为某注册过的Id之后，使用OpenSearch kvp的q=parentIdentifier（速度慢）或CQL/XML条件（速度快）写死来区分各个collection
- POST查询中Envelop的左下角右上角，先经度后纬度，±180和±90，见https://docs.opengeospatial.org/cs/17-002r1/17-002r1.html
- NASA要求有r={os:SearchTerms}，作为伪opensearch的任意字段查询，否则解析不了。有没有q影响不大
- 查询例子（经过了对上述pycsw的修改测试）：见Github  
https://github.com/Theropod/CWIC-OpenSearch/blob/main/csw-requests.md

### 程序管理
#### 版本控制  
- 生产环境（virtualenv pycsw）放了pycsw-2.6.0，已经同步了所有修改
- 开发环境（virtualenv pycsw-dev）目前是修改后的2.6.0。这个部分是git管理的，upstream是pycsw，orgin是我fork的pycsw版本，用来同步我的修改。2.8.0的正式版要是出来，就merge之后同步.

