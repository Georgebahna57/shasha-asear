$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$jsonPath = Join-Path $env:APPDATA "MetaQuotes\Terminal\Common\Files\shop-board.json"

function Get-LanIPv4 {
  try {
    return Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop |
      Where-Object {
        $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*"
      } |
      Select-Object -First 1 -ExpandProperty IPAddress
  } catch {
    return $null
  }
}

function Open-AppWindow([string]$appUrl) {
  $candidates = @(
    "C:\Program Files\Microsoft\Edge\Application\msedge.exe",
    "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    (Join-Path $env:LOCALAPPDATA "Google\Chrome\Application\chrome.exe")
  )
  $exe = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
  if ($exe) {
    Start-Process $exe -ArgumentList @("--app=$appUrl")
  } else {
    Start-Process $appUrl
  }
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:8765/")
$lanIp = Get-LanIPv4
if ($lanIp) {
  $listener.Prefixes.Add("http://${lanIp}:8765/")
}
try {
  $listener.Start()
} catch {
  Write-Host "Could not bind LAN. Run enable-lan-board.bat once as Administrator."
  try {
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://127.0.0.1:8765/")
    $listener.Start()
  } catch {
    Open-AppWindow "http://127.0.0.1:8765/"
    exit 0
  }
}

$openUrl = "http://127.0.0.1:8765/"
Open-AppWindow $openUrl
Write-Host "Shop board (this PC):  $openUrl"
if ($lanIp) {
  Write-Host "TV / phone (same Wi-Fi): http://${lanIp}:8765/"
  Write-Host "MT5 feed JSON:         http://${lanIp}:8765/prices.json"
}
Write-Host "MT5 file:              $jsonPath"
Write-Host "Keep this window open while the screen is showing."
Write-Host "Press Ctrl+C to stop."

function Read-SharedBytes([string]$path) {
  if (-not (Test-Path $path)) { return $null }
  for ($i = 0; $i -lt 4; $i++) {
    try {
      $fs = [IO.File]::Open($path, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite)
      try {
        $len = [int]$fs.Length
        if ($len -le 0) { return $null }
        $buf = New-Object byte[] $len
        [void]$fs.Read($buf, 0, $len)
        return $buf
      } finally {
        $fs.Close()
      }
    } catch {
      Start-Sleep -Milliseconds 15
    }
  }
  return $null
}

function Send-Response($response, [int]$code, [string]$contentType, [byte[]]$bytes) {
  $response.StatusCode = $code
  $response.Headers.Add("Access-Control-Allow-Origin", "*")
  $response.Headers.Add("Cache-Control", "no-store")
  $response.ContentType = $contentType
  $response.ContentLength64 = $bytes.Length
  $response.OutputStream.Write($bytes, 0, $bytes.Length)
  $response.OutputStream.Close()
}

try {
  while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $path = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath).TrimEnd("/")
    if ($path -eq "") { $path = "/index.html" }

    if ($ctx.Request.HttpMethod -eq "OPTIONS") {
      Send-Response $ctx.Response 204 "text/plain" @()
      continue
    }

    if ($path -eq "/prices.json") {
      $bytes = Read-SharedBytes $jsonPath
      if ($bytes -and $bytes.Length -gt 2) {
        Send-Response $ctx.Response 200 "application/json; charset=utf-8" $bytes
      } else {
        $msg = [Text.Encoding]::UTF8.GetBytes('{"error":"mt5-offline"}')
        Send-Response $ctx.Response 404 "application/json" $msg
      }
      continue
    }

    $file = [IO.Path]::GetFullPath((Join-Path $root ($path.TrimStart("/") -replace "/", [IO.Path]::DirectorySeparatorChar)))
    $rootFull = [IO.Path]::GetFullPath($root)
    if (-not (Test-Path $file) -or -not $file.StartsWith($rootFull, [StringComparison]::OrdinalIgnoreCase)) {
      $msg = [Text.Encoding]::UTF8.GetBytes("Not found")
      Send-Response $ctx.Response 404 "text/plain" $msg
      continue
    }

    $ext = [IO.Path]::GetExtension($file).ToLowerInvariant()
    $type = switch ($ext) {
      ".html" { "text/html; charset=utf-8" }
      ".js"   { "text/javascript; charset=utf-8" }
      ".css"  { "text/css; charset=utf-8" }
      ".json" { "application/json; charset=utf-8" }
      default { "application/octet-stream" }
    }
    Send-Response $ctx.Response 200 $type ([IO.File]::ReadAllBytes($file))
  }
} finally {
  $listener.Stop()
  $listener.Close()
}
