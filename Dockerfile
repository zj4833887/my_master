# 使用清华大学的 Ubuntu 镜像
FROM docker.mirrors.sjtug.sjtu.edu.cn/ubuntu:22.04

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 使用清华软件源
RUN sed -i 's@http://.*ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list

# 安装构建 Flutter Linux 应用所需的依赖
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    xz-utils \
    libglu1-mesa \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    && rm -rf /var/lib/apt/lists/*

# 设置 Flutter 环境变量
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$FLUTTER_HOME/bin:$PATH"

# 使用国内镜像下载 Flutter SDK
RUN git clone https://gitee.com/mirrors/flutter.git -b 3.10.6 $FLUTTER_HOME

# 设置国内环境变量
ENV PUB_HOSTED_URL=https://pub.flutter-io.cn
ENV FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# 预缓存 Linux 的构建资源
RUN flutter precache --linux

# 运行 flutter doctor 检查环境
RUN flutter doctor

# 设置容器启动后的默认工作目录为 /app
WORKDIR /app