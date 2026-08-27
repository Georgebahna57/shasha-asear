Set fso = CreateObject("Scripting.FileSystemObject")
Set sh = CreateObject("Wscript.Shell")
root = fso.GetParentFolderName(WScript.ScriptFullName)
ps1 = """" & root & "\start-board.ps1" & """"
sh.CurrentDirectory = root
sh.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File " & ps1, 0, False
