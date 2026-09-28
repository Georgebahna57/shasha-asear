Set sh = CreateObject("Wscript.Shell")
appUrl = "https://georgebahna57.github.io/shasha-asear/"
edge = "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
edge86 = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
Set fso = CreateObject("Scripting.FileSystemObject")

If fso.FileExists(edge) Then
  sh.Run """" & edge & """ --app=" & appUrl, 1, False
ElseIf fso.FileExists(edge86) Then
  sh.Run """" & edge86 & """ --app=" & appUrl, 1, False
Else
  sh.Run appUrl, 1, False
End If
