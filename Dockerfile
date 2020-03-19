FROM ubuntu:18.04

ENV BAZEL_VERSION 2.1.0
ENV GOLANG_VERSION 1.13.8
ENV PYTHON_VERSION 3.7.6

# 更换为阿里云境像
RUN sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list

RUN (apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        build-essential \
        software-properties-common \
        curl \
        wget \
        git \
        openssh-client \
        openjdk-11-jdk \
        g++ unzip zip \
        openjdk-11-jre-headless)

WORKDIR /tmp/
RUN (wget -P /tmp https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz)
RUN tar -zxvf Python-$PYTHON_VERSION.tgz
WORKDIR /tmp/Python-$PYTHON_VERSION
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get dist-upgrade -y

RUN export DEBIAN_FRONTEND=noninteractive && apt-get install -y tzdata
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN apt-get install -y --no-install-recommends libbz2-dev libncurses5-dev libgdbm-dev libgdbm-compat-dev liblzma-dev libsqlite3-dev libssl-dev openssl tk-dev uuid-dev libreadline-dev
RUN apt-get install -y --no-install-recommends libffi-dev
RUN ./configure --prefix=/usr/local/python3
RUN make
RUN make install
RUN update-alternatives --install /usr/bin/python python /usr/local/python3/bin/python3 1
RUN update-alternatives --install /usr/bin/pip pip /usr/local/python3/bin/pip3 1
RUN update-alternatives --config python
RUN update-alternatives --config pip
RUN pip install --upgrade pip
RUN (pip install -i http://mirrors.aliyun.com/pypi/simple --trusted-host mirrors.aliyun.com grpcio numpy && \
     touch /root/WORKSPACE)

RUN (curl -L https://dl.google.com/go/go$GOLANG_VERSION.linux-amd64.tar.gz | tar zx -C /usr/lib)

RUN (wget -P /tmp https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh)
RUN (chmod +x /tmp/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh)
RUN bash /tmp/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh
RUN echo "export PATH=$PATH:/usr/lib/go/bin" >> /root/.bashrc

# clean
RUN rm -rf /tmp/*
RUN  rm -rf /var/lib/apt/lists/*
RUN rm -rf /root/.cache/pip

WORKDIR /root

RUN mkdir /root/.pip
RUN echo "[global]" >> /root/.pip/pip.conf
RUN echo "index-url=http://mirrors.aliyun.com/pypi/simple/" >> /root/.pip/pip.conf
RUN echo "trusted-host=mirrors.aliyun.com" >> /root/.pip/pip.conf

RUN update-alternatives --install /usr/bin/python3 python3 /usr/local/python3/bin/python3 1
RUN update-alternatives --install /usr/bin/pip3 pip3 /usr/local/python3/bin/pip3 1
RUN update-alternatives --config python3
RUN update-alternatives --config pip3

# dirs for bazel build
RUN mkdir -p /root/cache/bazel
RUN mkdir -p /root/output

# https://github.com/pypa/pip/issues/4924
RUN mv /usr/bin/lsb_release /usr/bin/lsb_release.bak

RUN export PATH=$PATH:/usr/lib/go/bin

CMD ["bin/bash"]
