#!/bin/bash
# 使用包含 Flutter 和 ARM64 原生环境的官方镜像
docker run --rm -v $(pwd):/app -w /app cirrusci/flutter:stable bash -c "
  flutter config --enable-linux-desktop
  flutter clean
  flutter pub get
  # 关键：在支持多架构的镜像中，可以构建 arm64 版本
  flutter build linux --release --target-platform=linux-arm64
"
echo "构建完成！输出目录：$(pwd)/build/linux/arm64/release/bundle/"