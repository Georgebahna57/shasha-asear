$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$launcher = Join-Path $root "launch-app.vbs"
$edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if (-not (Test-Path $edge)) {
  $edge = "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
}

$appName = -join @(
  [char]0x0634, [char]0x0627, [char]0x0634, [char]0x0629, " ",
  [char]0x0623, [char]0x0633, [char]0x0639, [char]0x0627, [char]0x0631
)

$shell = New-Object -ComObject WScript.Shell
$startMenu = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\$appName.lnk"
$desktop = Join-Path ([Environment]::GetFolderPath("Desktop")) "$appName.lnk"

foreach ($path in @($startMenu, $desktop)) {
  $shortcut = $shell.CreateShortcut($path)
  $shortcut.TargetPath = "wscript.exe"
  $shortcut.Arguments = "`"$launcher`""
  $shortcut.WorkingDirectory = $root
  $shortcut.WindowStyle = 7
  $shortcut.Description = $appName
  if (Test-Path $edge) {
    $shortcut.IconLocation = "$edge,0"
  }
  $shortcut.Save()
}

Write-Host "Installed as a Windows app: $appName"
Write-Host "Open it from the Start menu or Desktop."
Write-Host "It launches in its own window, not as a browser tab."
