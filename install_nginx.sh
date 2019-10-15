#!/usr/bin/env bash

INSTALL_DIR="/usr/local/src"
CONF_DIR="/usr/local/nginx/conf.d"
SSL_DIR="/usr/local/nginx/ssl"
LOGS_DIR="/usr/local/nginx/logs"
WORKER_NUMS=$(grep ^processor /proc/cpuinfo | wc -l)
NGINX_DIR="/usr/local/nginx"

echo -e "\033[32m =========== 开始安装 nginx========= \033[0m"
####安装依赖
yum install -y gcc gcc-c++ make libtool zlib zlib-devel pcre pcre-devel openssl openssl-devel wget unzip lua-devel patch epel-release

#####安装nginx及第三方模块
cd $INSTALL_DIR 
#安装依赖pcre
wget --no-check-certificate  http://downloads.sourceforge.net/project/pcre/pcre/8.39/pcre-8.39.tar.gz
#安装依赖zlib
wget http://zlib.net/zlib-1.2.11.tar.gz
#安装日志过滤模块，可以不记录特定日志
wget https://codeload.github.com/cfsego/ngx_log_if/zip/master -O ngx_log_if.zip
#安装echo模块，可以自定义输出
wget https://codeload.github.com/openresty/echo-nginx-module/zip/master -O echo-nginx-module.zip
#安装nginx_lua模块
wget http://luajit.org/download/LuaJIT-2.1.0-beta2.tar.gz
wget https://github.com/simplresty/ngx_devel_kit/archive/v0.3.0.tar.gz
wget https://github.com/openresty/lua-nginx-module/archive/v0.10.13.tar.gz
#安装基于cookie的会话保持模块
wget https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/get/master.tar.gz -O nginx-sticky-module-ng.tar.gz
#安装缓存清除模块
wget http://labs.frickle.com/files/ngx_cache_purge-2.3.tar.gz
#安装流量带宽请求状态统计模块
wget https://github.com/zls0424/ngx_req_status/archive/master.zip -O ngx_req_status.zip
#安装统计虚拟主机流量的模块
wget https://github.com/magicbear/ngx_realtime_request_module/archive/master.zip -O ngx_realtime_request.zip
#安装nginx-vts-exporter模块，可以查看nginx自身状态
wget https://github.com/vozlt/nginx-module-vts/archive/master.zip -O nginx-module-vts.zip
#安装geoip2核心识别库
wget https://github.com/maxmind/libmaxminddb/releases/download/1.3.2/libmaxminddb-1.3.2.tar.gz
#安装geoip2-nginx模块
wget https://github.com/TravelEngineers/ngx_http_geoip2_module/archive/master.zip -O ngx_http_geoip2_module.zip
#安装geoip2 IP地址库
wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz
#安装nginx
wget http://nginx.org/download/nginx-1.16.0.tar.gz

##############解压安装包
cd $INSTALL_DIR
tar zxf pcre-8.39.tar.gz
tar zxf zlib-1.2.11.tar.gz
unzip ngx_log_if.zip
unzip echo-nginx-module.zip
tar zxf LuaJIT-2.1.0-beta2.tar.gz
tar zxf v0.3.0.tar.gz
tar zxf v0.10.13.tar.gz
tar zxf nginx-sticky-module-ng.tar.gz
tar zxf ngx_cache_purge-2.3.tar.gz
unzip ngx_req_status.zip
unzip ngx_realtime_request.zip
unzip nginx-module-vts.zip
tar zxf libmaxminddb-1.3.2.tar.gz
unzip ngx_http_geoip2_module.zip
tar zxf GeoLite2-City.tar.gz
tar zxf GeoLite2-Country.tar.gz
tar zxf nginx-1.16.0.tar.gz

###########隐藏nginx版本号
sed -i "s/1.12.1/8.8.8/g" $INSTALL_DIR/nginx-1.16.0/src/core/nginx.h
sed -i "s/Server: nginx/Server: Abu-NB/g" $INSTALL_DIR/nginx-1.16.0/src/http/ngx_http_header_filter_module.c
sed -i "s/<center>nginx/<center>Abu-NB/g" $INSTALL_DIR/nginx-1.16.0/src/http/ngx_http_special_response.c

######安装pcre
cd $INSTALL_DIR/pcre-8.39
./configure  --enable-utf8 && make && make install

###安装zlib
cd $INSTALL_DIR/zlib-1.2.11
./configure && make && make install

###安装lua
cd $INSTALL_DIR/LuaJIT-2.1.0-beta2
make install PREFIX=/usr/local/luajit
echo "export LUAJIT_LIB=/usr/local/luajit/lib" >>/etc/profile
echo "export LUAJIT_INC=/usr/local/luajit/include/luajit-2.0" >>/etc/profile
source /etc/profile
ln -s /usr/local/luajit/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2
#cd $INSTALL_DIR/ngx_devel_kit-0.3.0
#cd $INSTALL_DIR/lua-nginx-module-0.10.13

###安装req_status
cd $INSTALL_DIR/nginx-1.16.0
patch -p1 < $INSTALL_DIR/ngx_req_status-master/write_filter-1.7.11.patch

##安装geoip2
cd $INSTALL_DIR/libmaxminddb-1.3.2
./configure && make && make check && make install
ldconfig
ln -s /usr/local/lib/libmaxminddb.so.0 /usr/lib64
mkdir /etc/geoip
find $INSTALL_DIR -name GeoLite2-City.mmdb -exec cp {} /etc/geoip/ \;
find $INSTALL_DIR -name GeoLite2-Country.mmdb -exec cp {} /etc/geoip/ \;

##安装nginx
groupadd nginx
useradd nginx -g nginx -M -s /sbin/nologin

cd $INSTALL_DIR/nginx-1.16.0
./configure --user=nginx --group=nginx \
--prefix=/usr/local/nginx --pid-path=/usr/local/nginx/nginx.pid \
--with-http_stub_status_module --with-http_ssl_module \
--with-http_addition_module --with-http_sub_module  --with-http_flv_module --with-http_mp4_module \
--with-pcre=/usr/local/src/pcre-8.39  --with-http_dav_module \
--with-http_realip_module --with-http_gzip_static_module \
--add-module=/usr/local/src/ngx_log_if-master \
--add-module=/usr/local/src/echo-nginx-module-master \
--add-module=/usr/local/src/ngx_cache_purge-2.3 \
--add-module=/usr/local/src/nginx-goodies-nginx-sticky-module-ng-08a395c66e42 \
--add-module=/usr/local/src/ngx_req_status-master \
--add-module=/usr/local/src/nginx-module-vts-master \
--add-module=/usr/local/src/ngx_realtime_request_module-master \
--add-module=/usr/local/src/ngx_http_geoip2_module-master \
--add-module=/usr/local/src/ngx_devel_kit-0.3.0 \
--add-module=/usr/local/src/lua-nginx-module-0.10.13
make -j2 && make install

###创建目录########
mkdir -p  /usr/local/nginx/ssl
mkdir -p /usr/local/nginx/conf.d

##########加权限 ######
chown -R nginx:root /usr/local/nginx

#######nginx命令加入PATH####
ln -s /usr/local/nginx/sbin/nginx /usr/bin 

echo -e "\033[32m 安装完成 \033[0m"

#########修改配置文件###########
mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf-back
cd /usr/local/nginx/conf && find / -name nginx.conf -exec cp {} ./ \;

echo -e "\033[32m =====安装完毕===== \033[0m"
nginx -t
if [ $? -eq 0 ];then  
	echo -e "\033[32m =====配置文件正确，请启动===== \033[0m"
else
	echo -e "\033[32m =====配置文件错误，请检查===== \033[0m"
fi
