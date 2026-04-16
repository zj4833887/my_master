#!/bin/bash

echo "开始构建 Flutter Linux ARM64 应用..."

# 使用 Docker 容器进行构建
docker run --rm -v $(pwd):/app -w /app cirrusci/flutter:stable bash -c "
  echo '步骤 1/4: 启用 Linux 桌面支持...'
  flutter config --enable-linux-desktop

  echo '步骤 2/4: 清理旧构建并获取依赖...'
  flutter clean
  flutter pub get

  echo '步骤 3/4: 构建 Linux ARM64 版本 (这可能需要几分钟)...'
  flutter build linux --release --target-platform=linux-arm64

  echo '步骤 4/4: 构建完成！'
"

# 检查构建结果
if [ -d "build/linux/arm64/release/bundle/" ]; then
    echo "✅ 构建成功！"
    echo "📁 输出目录: $(pwd)/build/linux/arm64/release/bundle/"
    echo "📦 生成的文件包括:"
    ls -la "build/linux/arm64/release/bundle/"
else
    echo "❌ 构建失败，未找到输出目录。"
fi