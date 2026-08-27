$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$jsonPath = Join-Path $env:APPDATA "MetaQuotes\Terminal\Common\Files\shop-board.json"
$url = "http://127.0.0.1:8765/"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
try {
  $listener.Start()
} catch {
  Write-Host "Could not start local server. Is another copy already running?"
  Write-Host $_.Exception.Message
  Read-Host "Press Enter to close"
  exit 1
}

Start-Process $url
Write-Host "Shop board: $url"
Write-Host "MT5 file:   $jsonPath"
Write-Host "Keep this window open while the screen is showing."
Write-Host "Press Ctrl+C to stop."

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
      if (Test-Path $jsonPath) {
        $bytes = [System.IO.File]::ReadAllBytes($jsonPath)
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
