@echo off
echo Allowing shop board on your Wi-Fi (run once as Administrator)...
netsh http add urlacl url=http://+:8765/ user=%USERNAME%
if errorlevel 1 (
  echo Failed. Right-click this file and choose "Run as administrator".
) else (
  echo OK. Now run start-board.bat — TV can open http://YOUR-PC-IP:8765/
)
pause
