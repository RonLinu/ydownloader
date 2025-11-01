Set WshShell = WScript.CreateObject("WScript.Shell")

' Get the directory of the script file
Set fso = CreateObject("Scripting.FileSystemObject")
scriptPath = WScript.ScriptFullName
scriptDir = fso.GetParentFolderName(scriptPath)

' Change current directory to script directory
WshShell.CurrentDirectory = scriptDir

WshShell.Run "cmd /c node websocket.js https://ronlinu.github.io/ydownloader 8080", 0, True
