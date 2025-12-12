# PowerShell脚本：检查接口返回的base64是否是目前显示的底图
# 使用方法：
#   1. 从接口响应中提取BgImg字段的base64字符串，保存到文件（如：api_response.json）
#   2. 运行: .\check_base64_map.ps1 -Base64File "api_response.json" -Base64Field "BgImg"
#   或者直接提供base64字符串: .\check_base64_map.ps1 -Base64String "base64字符串"

param(
    [string]$Base64File = "",      # JSON文件路径，包含接口响应
    [string]$Base64Field = "BgImg", # JSON中base64字段名
    [string]$Base64String = "",    # 直接提供base64字符串
    [string]$LocalMapPath = "assets\images\device_map.png"  # 本地底图路径
)

# 设置错误处理
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "检查接口返回的base64底图" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. 获取base64字符串
$base64Data = ""

if ($Base64String -ne "") {
    Write-Host "[1/4] 使用提供的base64字符串" -ForegroundColor Yellow
    $base64Data = $Base64String
} elseif ($Base64File -ne "" -and (Test-Path $Base64File)) {
    Write-Host "[1/4] 从文件读取base64: $Base64File" -ForegroundColor Yellow
    try {
        $jsonContent = Get-Content -Path $Base64File -Raw -Encoding UTF8 | ConvertFrom-Json
        
        # 尝试从嵌套结构中提取BgImg
        $bgImg = $null
        
        # 检查直接字段
        if ($jsonContent.PSObject.Properties.Name -contains $Base64Field) {
            $bgImg = $jsonContent.$Base64Field
        }
        # 检查RouteMapSettings数组
        elseif ($jsonContent.PSObject.Properties.Name -contains "RouteMapSettings" -and 
                $jsonContent.RouteMapSettings -is [System.Array] -and 
                $jsonContent.RouteMapSettings.Count -gt 0) {
            $bgImg = $jsonContent.RouteMapSettings[0].$Base64Field
        }
        # 检查data字段
        elseif ($jsonContent.PSObject.Properties.Name -contains "data") {
            $data = $jsonContent.data
            if ($data.PSObject.Properties.Name -contains $Base64Field) {
                $bgImg = $data.$Base64Field
            }
        }
        
        if ($null -eq $bgImg -or $bgImg -eq "") {
            Write-Host "错误: 在JSON中未找到字段 '$Base64Field'" -ForegroundColor Red
            Write-Host "可用的字段: $($jsonContent.PSObject.Properties.Name -join ', ')" -ForegroundColor Yellow
            exit 1
        }
        
        $base64Data = $bgImg.ToString()
        Write-Host "成功提取base64数据，长度: $($base64Data.Length) 字符" -ForegroundColor Green
    } catch {
        Write-Host "错误: 无法解析JSON文件: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "错误: 请提供Base64File或Base64String参数" -ForegroundColor Red
    Write-Host ""
    Write-Host "使用方法:" -ForegroundColor Yellow
    Write-Host "  .\check_base64_map.ps1 -Base64File `"api_response.json`" -Base64Field `"BgImg`"" -ForegroundColor White
    Write-Host "  .\check_base64_map.ps1 -Base64String `"base64字符串`"" -ForegroundColor White
    exit 1
}

# 清理base64字符串（移除可能的data:image前缀）
$base64Data = $base64Data -replace "^data:image/[^;]+;base64,", ""

if ($base64Data.Length -eq 0) {
    Write-Host "错误: base64数据为空" -ForegroundColor Red
    exit 1
}

# 2. 将base64解码为图片文件
Write-Host ""
Write-Host "[2/4] 解码base64为图片文件..." -ForegroundColor Yellow
$tempImagePath = "temp_api_map_$(Get-Date -Format 'yyyyMMddHHmmss').png"

try {
    $bytes = [System.Convert]::FromBase64String($base64Data)
    [System.IO.File]::WriteAllBytes($tempImagePath, $bytes)
    Write-Host "成功解码，保存到: $tempImagePath" -ForegroundColor Green
    Write-Host "图片大小: $($bytes.Length) 字节" -ForegroundColor Green
} catch {
    Write-Host "错误: base64解码失败: $_" -ForegroundColor Red
    exit 1
}

# 3. 检查本地底图文件
Write-Host ""
Write-Host "[3/4] 检查本地底图文件..." -ForegroundColor Yellow

if (-not (Test-Path $LocalMapPath)) {
    Write-Host "警告: 本地底图文件不存在: $LocalMapPath" -ForegroundColor Yellow
    Write-Host "将只显示接口返回的图片" -ForegroundColor Yellow
    $localBytes = $null
} else {
    $localBytes = [System.IO.File]::ReadAllBytes($LocalMapPath)
    Write-Host "本地底图文件存在: $LocalMapPath" -ForegroundColor Green
    Write-Host "本地图片大小: $($localBytes.Length) 字节" -ForegroundColor Green
}

# 4. 比较两个图片
Write-Host ""
Write-Host "[4/4] 比较图片..." -ForegroundColor Yellow
Write-Host ""

if ($null -ne $localBytes) {
    # 字节级比较
    $isIdentical = $true
    if ($bytes.Length -ne $localBytes.Length) {
        $isIdentical = $false
        Write-Host "❌ 图片大小不同:" -ForegroundColor Red
        Write-Host "   接口返回: $($bytes.Length) 字节" -ForegroundColor Yellow
        Write-Host "   本地底图: $($localBytes.Length) 字节" -ForegroundColor Yellow
    } else {
        Write-Host "✓ 图片大小相同: $($bytes.Length) 字节" -ForegroundColor Green
        
        # 逐字节比较
        $diffCount = 0
        $maxDiffs = 10
        for ($i = 0; $i -lt $bytes.Length; $i++) {
            if ($bytes[$i] -ne $localBytes[$i]) {
                $diffCount++
                if ($diffCount -le $maxDiffs) {
                    Write-Host "   位置 $i: 接口=$($bytes[$i]) 本地=$($localBytes[$i])" -ForegroundColor Yellow
                }
                $isIdentical = $false
            }
        }
        
        if ($diffCount -gt $maxDiffs) {
            Write-Host "   ... 还有 $($diffCount - $maxDiffs) 处不同" -ForegroundColor Yellow
        }
        
        if ($isIdentical) {
            Write-Host ""
            Write-Host "✅ 图片完全相同！接口返回的base64就是当前显示的底图。" -ForegroundColor Green
        } else {
            Write-Host ""
            Write-Host "❌ 图片不同！共发现 $diffCount 处差异。" -ForegroundColor Red
            Write-Host "   接口返回的base64与当前显示的底图不一致。" -ForegroundColor Red
        }
    }
    
    # 计算MD5哈希进行快速比较
    Write-Host ""
    Write-Host "MD5哈希比较:" -ForegroundColor Cyan
    $md5 = [System.Security.Cryptography.MD5]::Create()
    $apiHash = [System.BitConverter]::ToString($md5.ComputeHash($bytes)) -replace "-", ""
    $localHash = [System.BitConverter]::ToString($md5.ComputeHash($localBytes)) -replace "-", ""
    Write-Host "   接口返回: $apiHash" -ForegroundColor Yellow
    Write-Host "   本地底图: $localHash" -ForegroundColor Yellow
    
    if ($apiHash -eq $localHash) {
        Write-Host "   ✅ MD5哈希相同" -ForegroundColor Green
    } else {
        Write-Host "   ❌ MD5哈希不同" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️  无法比较（本地底图不存在），接口返回的图片已保存到: $tempImagePath" -ForegroundColor Yellow
}

# 5. 显示图片信息
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "图片信息" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 尝试获取图片尺寸（需要.NET图像处理）
try {
    Add-Type -AssemblyName System.Drawing
    $apiImage = [System.Drawing.Image]::FromFile((Resolve-Path $tempImagePath).Path)
    Write-Host "接口返回图片尺寸: $($apiImage.Width) x $($apiImage.Height)" -ForegroundColor Green
    Write-Host "接口返回图片格式: $($apiImage.RawFormat)" -ForegroundColor Green
    $apiImage.Dispose()
    
    if ($null -ne $localBytes) {
        $localImagePath = (Resolve-Path $LocalMapPath).Path
        $localImage = [System.Drawing.Image]::FromFile($localImagePath)
        Write-Host "本地底图尺寸: $($localImage.Width) x $($localImage.Height)" -ForegroundColor Green
        Write-Host "本地底图格式: $($localImage.RawFormat)" -ForegroundColor Green
        $localImage.Dispose()
    }
} catch {
    Write-Host "无法读取图片详细信息: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "临时文件: $tempImagePath" -ForegroundColor Gray
Write-Host "提示: 可以手动打开这两个图片文件进行视觉比较" -ForegroundColor Gray
Write-Host ""

