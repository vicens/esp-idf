FROM ubuntu:18.04

MAINTAINER HuiQian Shi shihuiqian@ju.ink

# IDF安装路径
ENV IDF_PATH /opt/esp
ENV IDF_TOOLS_PATH $IDF_PATH/.espressif
ENV IDF_CCACHE_ENABLE=1

# 替换为阿里云源
RUN sed -i 's#archive.ubuntu.com#mirrors.aliyun.com#' /etc/apt/sources.list \
    && apt update

# 安装依赖
RUN apt install -y  git \
                    wget \
                    make \
                    flex \
                    bison \
                    gperf \
                    unzip \
                    gcc-multilib \
                    libssl-dev \
                    libncurses-dev \
                    libreadline-dev \
                    cmake \
                    ninja-build \
                    ccache \
                    libffi-dev \
                    dfu-util

# 安装python3
RUN apt install -y python3 \
                   python3-pip \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && ln -s /usr/bin/pip3 /usr/bin/pip \
    # 升级pip
    && python -m pip install --trusted-host=mirrors.aliyun.com -i https://mirrors.aliyun.com/pypi/simple/ --upgrade pip \
    && pip install --trusted-host=mirrors.aliyun.com -i https://mirrors.aliyun.com/pypi/simple/ setuptools wheel aos-cube esptool pyserial scons

# 获取IDF
RUN mkdir -p $IDF_PATH && cd $IDF_PATH \
    && git clone -b v4.2 --recursive https://github.com/espressif/esp-idf.git $IDF_PATH
RUN $IDF_PATH/install.sh

# 生成entrypoint
RUN echo "#!/usr/bin/env bash\n \
set -e\n \
export IDF_PATH=$IDF_PATH\n \
export IDF_TOOLS_PATH=$IDF_TOOLS_PATH\n \
# 导出环境变量 \
. \$IDF_PATH/export.sh\n \
exec \"\$@\"\n \
" >> /root/entrypoint.sh \
   && chmod +x /root/entrypoint.sh

WORKDIR $IDF_PATH

ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["/bin/bash"]

