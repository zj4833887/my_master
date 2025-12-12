# 辅助脚本：从接口响应中提取base64数据
# 使用方法：
#   .\extract_base64_from_response.ps1 -ResponseFile "response.json" -OutputFile "base64_output.txt"

param(
    [Parameter(Mandatory=$true)]
    [string]$ResponseFile,      # 接口响应JSON文件
    
    [string]$OutputFile = "extracted_base64.txt",  # 输出的base64文件
    [string]$Base64Field = "BgImg"  # base64字段名
)

$ErrorActionPreference = "Stop"

Write-Host "从接口响应中提取base64数据..." -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $ResponseFile)) {
    Write-Host "错误: 文件不存在: $ResponseFile" -ForegroundColor Red
    exit 1
}

try {
    $jsonContent = Get-Content -Path $ResponseFile -Raw -Encoding UTF8 | ConvertFrom-Json
    
    # 尝试从多个可能的位置提取BgImg
    $bgImg = $null
    $foundPath = ""
    
    # 1. 直接字段
    if ($jsonContent.PSObject.Properties.Name -contains $Base64Field) {
        $bgImg = $jsonContent.$Base64Field
        $foundPath = "根级别.$Base64Field"
    }
    # 2. RouteMapSettings数组
    elseif ($jsonContent.PSObject.Properties.Name -contains "RouteMapSettings") {
        if ($jsonContent.RouteMapSettings -is [System.Array] -and $jsonContent.RouteMapSettings.Count -gt 0) {
            $firstSetting = $jsonContent.RouteMapSettings[0]
            if ($firstSetting.PSObject.Properties.Name -contains $Base64Field) {
                $bgImg = $firstSetting.$Base64Field
                $foundPath = "RouteMapSettings[0].$Base64Field"
            }
        }
    }
    # 3. data字段
    elseif ($jsonContent.PSObject.Properties.Name -contains "data") {
        $data = $jsonContent.data
        if ($data.PSObject.Properties.Name -contains $Base64Field) {
            $bgImg = $data.$Base64Field
            $foundPath = "data.$Base64Field"
        }
        # 检查data中的RouteMapSettings
        if ($null -eq $bgImg -and $data.PSObject.Properties.Name -contains "RouteMapSettings") {
            if ($data.RouteMapSettings -is [System.Array] -and $data.RouteMapSettings.Count -gt 0) {
                $firstSetting = $data.RouteMapSettings[0]
                if ($firstSetting.PSObject.Properties.Name -contains $Base64Field) {
                    $bgImg = $firstSetting.$Base64Field
                    $foundPath = "data.RouteMapSettings[0].$Base64Field"
                }
            }
        }
    }
    
    if ($null -eq $bgImg -or $bgImg -eq "") {
        Write-Host "错误: 在JSON中未找到字段 '$Base64Field'" -ForegroundColor Red
        Write-Host ""
        Write-Host "JSON结构预览:" -ForegroundColor Yellow
        Write-Host ($jsonContent | ConvertTo-Json -Depth 3 | Select-Object -First 50)
        Write-Host ""
        Write-Host "可用的根级别字段: $($jsonContent.PSObject.Properties.Name -join ', ')" -ForegroundColor Yellow
        exit 1
    }
    
    $base64String = $bgImg.ToString()
    
    # 清理base64字符串
    $base64String = $base64String -replace "^data:image/[^;]+;base64,", ""
    
    Write-Host "✓ 成功提取base64数据" -ForegroundColor Green
    Write-Host "  位置: $foundPath" -ForegroundColor Gray
    Write-Host "  长度: $($base64String.Length) 字符" -ForegroundColor Gray
    Write-Host ""
    
    # 保存到文件
    $base64String | Out-File -FilePath $OutputFile -Encoding UTF8 -NoNewline
    Write-Host "✓ 已保存到: $OutputFile" -ForegroundColor Green
    Write-Host ""
    Write-Host "现在可以运行检查脚本:" -ForegroundColor Cyan
    Write-Host "  .\check_base64_map.ps1 -Base64String `"$($base64String.Substring(0, [Math]::Min(50, $base64String.Length)))...`"" -ForegroundColor White
    Write-Host "或者:" -ForegroundColor Cyan
    Write-Host "  .\check_base64_map.ps1 -Base64File `"$OutputFile`"" -ForegroundColor White
    
} catch {
    Write-Host "错误: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

