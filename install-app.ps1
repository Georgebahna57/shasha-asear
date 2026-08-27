$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$launcher = Join-Path $root "launch-app.vbs"
$edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if (-not (Test-Path $edge)) {
  $edge = "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
}

$shell = New-Object -ComObject WScript.Shell
$startMenu = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\شاشة أسعار.lnk"
$desktop = Join-Path ([Environment]::GetFolderPath("Desktop")) "شاشة أسعار.lnk"

foreach ($path in @($startMenu, $desktop)) {
  $shortcut = $shell.CreateShortcut($path)
  $shortcut.TargetPath = "wscript.exe"
  $shortcut.Arguments = "`"$launcher`""
  $shortcut.WorkingDirectory = $root
  $shortcut.WindowStyle = 7
  $shortcut.Description = "شاشة أسعار المحل"
  if (Test-Path $edge) {
    $shortcut.IconLocation = "$edge,0"
  }
  $shortcut.Save()
}

Write-Host "Installed as a Windows app."
Write-Host "Start Menu / Desktop: شاشة أسعار"
Write-Host "Open it from there — it launches in its own window, not as a browser tab."
