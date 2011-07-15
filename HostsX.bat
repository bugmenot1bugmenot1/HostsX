@echo off
SETLOCAL EnableExtensions
SetLocal EnableDelayedExpansion
mode con cols=30 lines=10
title HostsX.Bat
set/a xc=%random%%%5+1
set te=
for %%i in (c d e f a) do (
set /a te=!!te!+1!
if "!xc!"=="!te!" set xc=%%i)
color 0%xc%
If "%PROCESSOR_ARCHITECTURE%"=="AMD64" (Set a=%SystemRoot%\SysWOW64) Else (Set a=%SystemRoot%\system32)
Md "%a%\test_permissions" 2>nul||(echo 请使用右键管理员身份运行! & choice /t 2 /d y /n >nul &Exit)
Rd "%a%\test_permissions"
set bak=%date:~0,4%年%date:~5,2%月%date:~8,2%日%time:~0,2%时备份
set etc=%windir%\system32\drivers\etc
set hosts=%windir%\system32\drivers\etc\hosts
ipv6install>nul 2>nul
net stop "Dnscache">nul 2>nul
sc stop "DNSCache">nul 2>nul
sc config Dnscache start= disabled>nul 2>nul
sc config iphlpsvc start= AUTO>nul 2>nul
if not exist %etc%\ md %etc%\ >nul
takeown /F %etc%\ /R >nul
copy /y %hosts% %etc%\"Hosts_%bak%.txt" >nul 2>nul
echo Backup completed!

:dftvbs
echo y| cacls %hosts% /c /t /p everyone:f >nul 2>nul
attrib %hosts% -r -h -s >nul 2>nul
ping /n 2 hostsx.googlecode.com >nul||goto dftlocal
echo Update Hosts Data...
echo Please wait...
echo Set oDOM = WScript.GetObject(WScript.Arguments(0)) >%temp%/Updates.vbs
echo do until oDOM.readyState = "complete" >>%temp%/Updates.vbs
echo WScript.sleep 200 >>%temp%/Updates.vbs
echo loop >>%temp%/Updates.vbs
echo WScript.echo oDOM.documentElement.outerText >>%temp%/Updates.vbs
cscript //NoLogo /e:vbscript %temp%/Updates.vbs "http://hostsx.googlecode.com/svn/trunk/HostsX.orzhosts">%temp%\HostsX.orzhosts
set size=200000
for %%1 in (%temp%\HostsX.orzhosts)do set gsize=%%~z1
if %gsize% gtr %size% (copy %temp%\HostsX.orzhosts %hosts%)
if %gsize% lss %size% mshta vbscript:msgbox("Connection Refused by Server!",64,"G+ Hosts")(window.close) & goto menu
echo 0.0.0.0 %date:~0,4%%date:~5,2%%date:~8,2%.biz5.sandai.net>>%hosts%
del %etc%\HostsX.orzhosts & copy %temp%\HostsX.orzhosts %etc%\HostsX.orzhosts
goto perms

:dftlocal
echo 无法连接服务器！& choice /t 2 /d y /n >nul
echo 或将使用本地缓存Hosts数据！& choice /t 2 /d y /n >nul
if not exist %etc%\HostsX.orzhosts (echo 未找到本地缓存Hosts数据! & choice /t 2 /d y /n >nul&exit) else (copy %etc%\HostsX.orzhosts %hosts% &echo 已更换至本地缓存Hosts数据！)
goto perms

:perms
notepad %hosts%
echo y| cacls %hosts% /c /t /p everyone:f >nul 2>nul
attrib +r -h +s %hosts% >nul 2>nul
echo y| cacls %hosts% /c /t /p everyone:r >nul
ipconfig /flushdns>nul 2>nul
del /f /s /q "%userprofile%\local Settings\temporary Internet Files\*.*">nul 2>nul
del /f /s /q "%userprofile%\local Settings\temp\*.*">nul 2>nul
del /f /s /q "%userprofile%\recent\*.*">nul 2>nul
del /f /q %userprofile%\recent\*.*>nul 2>nul
reg delete "hkcu\Software\Microsoft\MediaPlayer\Services\FaroLatino_CN" /f >nul 2>nul
reg delete "hkcu\Software\Microsoft\MediaPlayer\Subscriptions" /f >nul 2>nul
reg delete "hklm\SOFTWARE\Microsoft\MediaPlayer\services\FaroLatino_CN" /f> nul 2>nul
ipconfig /flushdns>nul 2>nul&cls&echo HostsX data has been updated！ & choice /t 2 /d y /n >nul &Exit