FROM ubuntu:18.04

ENV BAZEL_VERSION 2.1.0
ENV GOLANG_VERSION 1.13.8
ENV PYTHON_VERSION 3.7.6
ENV PROTOBUF_VERSION=3.6.1
ENV NODEJS_VERSION 12

# 更换为阿里云境像
RUN sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list

RUN (apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        build-essential \
        software-properties-common \
        curl \
        wget \
        git \
        gnupg \
        libopenblas-dev \
        liblapack-dev \
        libssl-dev \
        libmetis-dev \
        pkg-config \
        zlib1g-dev \
        openssh-client \
        openjdk-11-jdk \
        g++ unzip zip \
        openjdk-11-jre-headless)

# Install nodejs yarn
RUN curl -sL https://deb.nodesource.com/setup_${NODEJS_VERSION}.x | bash -
RUN apt-get install -y nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN	echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn

# Install Python
WORKDIR /tmp/
RUN (wget -P /tmp https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz)
RUN tar -zxvf Python-$PYTHON_VERSION.tgz
WORKDIR /tmp/Python-$PYTHON_VERSION
RUN apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y

RUN export DEBIAN_FRONTEND=noninteractive && apt-get install -y tzdata
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN apt-get install -y --no-install-recommends libbz2-dev libncurses5-dev libgdbm-dev libgdbm-compat-dev liblzma-dev libsqlite3-dev libssl-dev openssl tk-dev uuid-dev libreadline-dev
RUN apt-get install -y --no-install-recommends libffi-dev
RUN ./configure --prefix=/usr/local/python3 && \
        make && \
        make install
RUN update-alternatives --install /usr/bin/python python /usr/local/python3/bin/python3 1
RUN update-alternatives --install /usr/bin/pip pip /usr/local/python3/bin/pip3 1
RUN update-alternatives --config python
RUN update-alternatives --config pip
RUN pip install --upgrade pip
RUN (pip install -i http://mirrors.aliyun.com/pypi/simple --trusted-host mirrors.aliyun.com grpcio numpy && \
     touch /root/WORKSPACE)

# Install Golang
RUN (curl -L https://dl.google.com/go/go$GOLANG_VERSION.linux-amd64.tar.gz | tar zx -C /usr/local)
ENV PATH /usr/local/go/bin:$PATH
RUN mkdir -p /go/src /go/bin && chmod -R 777 /go
ENV GOROOT /usr/local/go
ENV GOPATH /go
ENV PATH /go/bin:$PATH

# Install go packages
RUN go env -w GO111MODULE=on && \
	go env -w GOPROXY=https://goproxy.io,direct
COPY go.mod /go.mod
RUN go mod download

# Install proto buffer
# refer to https://github.com/golang/protobuf
RUN wget -P /tmp https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip
RUN unzip /tmp/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip -d protoc3 && \
	rm /tmp/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip
RUN mv protoc3/bin/* /usr/local/bin/ && mv protoc3/include/* /usr/local/include/

# Install GoLang proto gen
RUN go get -u -v github.com/golang/protobuf/protoc-gen-go

# Manually clone golang.org/x/XXX packages from their github mirrors.
# F**K GFW!
WORKDIR /go/src/golang.org/x/
RUN git clone --progress https://github.com/golang/debug.git && \
git clone --progress https://github.com/golang/glog.git && \
git clone --progress https://github.com/golang/time.git && \
git clone --progress https://github.com/golang/sync.git && \
git clone --progress https://github.com/golang/crypto && \
git clone --progress https://github.com/golang/tools && \
git clone --progress https://github.com/golang/sys

# Install packr2
RUN go get -u github.com/gobuffalo/packr/v2/packr2

# Install bazel
RUN (wget -P /tmp https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh)
RUN (chmod +x /tmp/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh)
RUN bash /tmp/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh

# clean
RUN rm -rf /tmp/* && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /root/.cache/pip

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
RUN mkdir -p /root/cache/bazel && \
mkdir -p /root/output

# https://github.com/pypa/pip/issues/4924
RUN mv /usr/bin/lsb_release /usr/bin/lsb_release.bak

CMD ["bin/bash"]
