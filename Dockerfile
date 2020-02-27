FROM centos:7

MAINTAINER sunnywalden@gmail.com

USER root

ENV PYTHON_VERSION=3.7.6 \
    SSL_VERSION=1_1_1d

RUN yum install -y wget && \
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup && \
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && \
    yum -y install epel-release && \
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo && \
    yum clean all && \
    yum makecache && \
    rm -rf /var/cache/yum/* \
    rm -fr /tmp/*
    
RUN yum -y install gcc automake autoconf libtool make zlib zlib-devel  libffi-devel mariadb-devel && \
    wget https://github.com/openssl/openssl/archive/OpenSSL_${SSL_VERSION}.tar.gz && \
    tar -zxf OpenSSL_${SSL_VERSION}.tar.gz && \
    cd openssl-OpenSSL_${SSL_VERSION} && \
    ./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl shared zlib && \
    make && make install && \
    if [ -f '/usr/bin/openssl' ];then rm -rf /usr/bin/openssl;fi && \
    if [-d '/usr/include/openssl' ];then rm -rf /usr/include/openssl;fi && \
    ln -s /usr/local/openssl/include/openssl /usr/include/openssl && \
    ln -s /usr/local/openssl/lib/libssl.so.1.1 /usr/local/lib64/libssl.so && \
    ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl && \
    echo 'pathmunge /usr/local/openssl/bin' > /etc/profile.d/openssl.sh && \
    echo '/usr/local/openssl/lib' > /etc/ld.so.conf.d/openssl-${SSL_VERSION}.conf && \
    ldconfig -v && \
    cd .. && \
    rm -rf *OpenSSL_${SSL_VERSION}* && \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz && \
    tar -Jxf Python-${PYTHON_VERSION}.tar.xz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --prefix=/usr/local/python3 --with-openssl=/usr/local/openssl && \
    make && make install && \
    rm -rf /usr/bin/python && rm -rf /usr/bin/pip && \
    ln -s /usr/local/python3/bin/python3 /usr/bin/python && \
    ln -s /usr/local/python3/bin/pip3 /usr/bin/pip && \
    sed -i 's/\/usr\/bin\/python/\/usr\/bin\/python2.7/g' /usr/bin/yum-config-manager && \
    sed -i 's/\/usr\/bin\/python/\/usr\/bin\/python2.7/g' /usr/libexec/urlgrabber-ext-down && \
    sed -i 's/\/usr\/bin\/python/\/usr\/bin\/python2.7/g' /usr/bin/yum && \
    cd .. && \
    rm -rf Python-${PYTHON_VERSION}* && \
    mkdir -p ~/.pip/ && \
    echo "[global]" > ~/.pip/pip.conf && \
    echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> ~/.pip/pip.conf && \
    pip install --no-cache-dir --upgrade pip && \
    python -v && \
    yum install -y openssl && \
    yum clean all && \
    rm -rf /var/cache/yum/* \
    yum clean all && \
    rm -fr /tmp/*
