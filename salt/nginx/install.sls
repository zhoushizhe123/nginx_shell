add_nginx_group:
  group.present:
    - name: nginx

nginx:
  user.present:
    - fullname: nginx
    - shell: /sbin/nologin
    - createhome: False
    - groups:
      - nginx

dep_packages:
  pkg.installed:
    - pkgs:
      - gcc-c++
      - gcc
      - make
      - libtool
      - zlib
      - zlib-devel
      - pcre-devel
      - pcre
      - openssl
      - openssl-devel
      - wget
      - unzip
      - lua-devel
      - patch
      - epel-release

module_pcre:
  cmd.run:
    - cwd: /usr/local/src
    - name: wget --no-check-certificate http://downloads.sourceforge.net/project/pcre/pcre/8.39/pcre-8.39.tar.gz && tar zxf pcre-8.39.tar.gz && cd pcre-8.39 && ./configure && make && make install 
    - unless: test -f pcre-8.39.tar.gz

module_zlib:
  cmd.run:
    - cwd: /usr/local/src
    - name: wget http://zlib.net/zlib-1.2.11.tar.gz && tar zxf zlib-1.2.11.tar.gz && cd zlib-1.2.11 && ./configure && make && make install
    - unless: test -f zlib-1.2.11.tar.gz

module_ngx_log:
  cmd.run:
    - cwd: /usr/local/src
    - name: wget https://codeload.github.com/cfsego/ngx_log_if/zip/master -O ngx_log_if.zip && unzip ngx_log_if.zip
    - unless: test -f ngx_log_if.zip

modlue_echo-nginx:
  cmd.run:
    - cwd: /usr/local/src
    - name: wget https://codeload.github.com/openresty/echo-nginx-module/zip/master -O echo-nginx-module.zip && unzip echo-nginx-module.zip
    - unless: test -f echo-nginx-module.zip

module_lua-nginx1:
  cmd.run:
    - cwd: /usr/local/src
    - name: wget http://luajit.org/download/LuaJIT-2.1.0-beta2.tar.gz && tar zxf LuaJIT-2.1.0-beta2.tar.gz
    - unless: test -f LuaJIT-2.1.0-beta2.tar.gz

module_lua-nginx2:
  cmd.run:
    - cwd: /usr/local/src
    - name: wget https://github.com/simplresty/ngx_devel_kit/archive/v0.3.0.tar.gz && tar zxf v0.3.0.tar.gz 
    - unless: test -f v0.3.0.tar.gz

module_lua-nginx3:
  cmd.run:
    - cwd: /usr/local/src
    - name: wget https://github.com/openresty/lua-nginx-module/archive/v0.10.13.tar.gz && tar zxf v0.10.13.tar.gz && cd LuaJIT-2.1.0-beta2 && make install PREFIX=/usr/local/luajit && echo "export LUAJIT_LIB=/usr/local/luajit/lib" >>/etc/profile && echo "export LUAJIT_INC=/usr/local/luajit/include/luajit-2.0" >>/etc/profile && source /etc/profile && ln -s /usr/local/luajit/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2
    - unless: test -f v0.10.13.tar.gz

module_nginx-sticky:
  cmd.run:
    - cwd: /usr/local/src
    - name: wget https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/get/master.tar.gz -O nginx-sticky-module-ng.tar.gz && tar zxf nginx-sticky-module-ng.tar.gz
    - unless: test -f nginx-sticky-module-ng.tar.gz

module_ngx_cache_purge:
  cmd.run:
    - cwd: /usr/local/src
    - name: wget http://labs.frickle.com/files/ngx_cache_purge-2.3.tar.gz && tar zxf ngx_cache_purge-2.3.tar.gz
    - unless: test -f ngx_cache_purge-2.3.tar.gz

nginx_source_code_install:
  cmd.run:
    - cwd: /usr/local/src
    - name: wget http://nginx.org/download/nginx-1.16.0.tar.gz && tar zxf nginx-1.16.0.tar.gz
    - unless: test -f nginx-1.16.0.tar.gz

nginx_hide_version:
  cmd.run:
    - cwd: /usr/local/src
    - name: sed -i "s/1.12.1/8.8.8/g" nginx-1.16.0/src/core/nginx.h

hide_version_file:
  file.recurse:
    - source: salt://nginx/hide_version
    - name: /usr/local/src/nginx-1.16.0/src/http

module_ngx_req_status:
  cmd.run:
    - cwd: /usr/local/src
    - name: wget https://github.com/zls0424/ngx_req_status/archive/master.zip -O ngx_req_status.zip && unzip ngx_req_status.zip && cd nginx-1.16.0 && patch -p1 < ../ngx_req_status-master/write_filter-1.7.11.patch
    - unless: test -f ngx_req_status.zip
    
module_ngx_realtime_request:
  cmd.run:  
    - cwd: /usr/local/src
    - name: wget https://github.com/magicbear/ngx_realtime_request_module/archive/master.zip -O ngx_realtime_request.zip && unzip ngx_realtime_request.zip
    - unless: test -f ngx_realtime_request.zip

module_nginx-module-vts:
  cmd.run:
    - cwd: /usr/local/src
    - name: wget https://github.com/vozlt/nginx-module-vts/archive/master.zip -O nginx-module-vts.zip && unzip nginx-module-vts.zip
    - unless: test -f nginx-module-vts.zip

module_geoip2:
  cmd.run:
    - cwd: /usr/local/src
    - name: wget https://github.com/maxmind/libmaxminddb/releases/download/1.3.2/libmaxminddb-1.3.2.tar.gz && tar zxf libmaxminddb-1.3.2.tar.gz
    - unless: test -f libmaxminddb-1.3.2.tar.gz

module_geoip2-nginx:
  cmd.run:
    - cwd: /usr/local/src
    - name: wget https://github.com/TravelEngineers/ngx_http_geoip2_module/archive/master.zip -O ngx_http_geoip2_module.zip && unzip ngx_http_geoip2_module.zip
    - unless: test -f ngx_http_geoip2_module.zip

module_GeoLite2:
  cmd.run:
    - cwd: /usr/local/src
    - name: wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz && tar zxf GeoLite2-City.tar.gz
    - unless: test -f GeoLite2-City.tar.gz

module_GeoLite2-1:
  cmd.run:
    - cwd: /usr/local/src
    - name: wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz && tar zxf GeoLite2-Country.tar.gz
    - unless: test -f GeoLite2-Country.tar.gz

module_geoip2_make:
  cmd.run:
    - cwd: /usr/local/src
    - name: cd libmaxminddb-1.3.2 && ./configure && make && make check && make install && ldconfig && ln -s /usr/local/lib/libmaxminddb.so.0 /usr/lib64 && mkdir /etc/geoip && find /usr/local/src -name GeoLite2-City.mmdb -exec cp {} /etc/geoip/ \; && find /usr/local/src -name GeoLite2-Country.mmdb -exec cp {} /etc/geoip/ \;
    - unless: test -d /etc/geoip

make_nginx:
  cmd.run:
    - cwd: /usr/local/src
    - name: cd nginx-1.16.0 && ./configure --user=nginx --group=nginx --prefix=/usr/local/nginx --pid-path=/usr/local/nginx/nginx.pid --with-http_stub_status_module --with-http_ssl_module --with-http_addition_module --with-http_sub_module  --with-http_flv_module --with-http_mp4_module --with-pcre=/usr/local/src/pcre-8.39  --with-http_dav_module --with-http_realip_module --with-http_gzip_static_module --add-module=/usr/local/src/ngx_log_if-master --add-module=/usr/local/src/echo-nginx-module-master --add-module=/usr/local/src/ngx_cache_purge-2.3 --add-module=/usr/local/src/nginx-goodies-nginx-sticky-module-ng-08a395c66e42 --add-module=/usr/local/src/ngx_req_status-master --add-module=/usr/local/src/nginx-module-vts-master --add-module=/usr/local/src/ngx_realtime_request_module-master --add-module=/usr/local/src/ngx_http_geoip2_module-master --add-module=/usr/local/src/ngx_devel_kit-0.3.0 --add-module=/usr/local/src/lua-nginx-module-0.10.13 && make -j2 && make install

nginx_sbin_nginx:
  cmd.run:
    - name: ln -s /usr/local/nginx/sbin/nginx /usr/bin


chown_nginx_dirs:
  cmd.run:
    - cwd: /usr/local/
    - name: chown -R nginx:root nginx

configFile:
  file.recurse:
    - name: /usr/local/nginx/conf
    - source: salt://nginx/conf
    - backup: minion

/usr/local/nginx/conf.d:
  file.directory:
    - user: nginx
    - group: root
    - mode: 755
    - makedirs: True

/usr/local/nginx/ssl:
  file.directory:
    - user: nginx
    - group: root
    - mode: 755
    - makedirs: True 
