FROM nginxinc/nginx-unprivileged:1.17.8 as build

# Reset user to root
USER 0

ADD install_packages /usr/sbin
RUN chmod +x /usr/sbin/install_packages

RUN install_packages \
    wget \
    nfs-common \
    apt-utils \
    autoconf \
    automake \
    build-essential \
    git \
    libcurl4-openssl-dev \
    libgeoip-dev \
    liblmdb-dev \
    libpcre++-dev \
    libtool \
    libxml2-dev \
    libyajl-dev \
    pkgconf \
    zlib1g-dev \
  && update-ca-certificates

RUN git clone --depth 1 https://github.com/openresty/headers-more-nginx-module.git \
  && wget http://nginx.org/download/nginx-1.17.8.tar.gz \
  && tar zxvf nginx-1.17.8.tar.gz \
  && rm -f nginx-1.17.8.tar.gz \
  && cd nginx-1.17.8 \
  && ./configure --with-compat --add-dynamic-module=../headers-more-nginx-module \
  && make modules \
  && cp objs/ngx_http_headers_more_filter_module.so /etc/nginx/modules \
  && cd / \
  && rm -rf /nginx-1.17.8 \
  && rm -rf /headers-more-nginx-module  

FROM nginxinc/nginx-unprivileged:1.17.8

USER 0

ADD install_packages /usr/sbin
RUN chmod +x /usr/sbin/install_packages 

RUN install_packages \
    apt-utils \
    openssl \
    libcurl4 \
    libgeoip1 \
    geoip-bin \
    liblmdb0 \
    libpcre++0v5 \
    libxml2 \
    libyajl2 \
    zlib1g \
  && update-ca-certificates

COPY --from=build /etc/nginx/modules/ngx_http_headers_more_filter_module.so /etc/nginx/modules/ngx_http_headers_more_filter_module.so

USER 101

CMD ["nginx", "-g", "daemon off;"]