taskkill /F /IM dserv.exe
sleep 1
del dserv.exe
nasm -f obj dserv.asm
alink -oPE -subsys windows dserv.obj C:\nasm\lib\win32.lib
del *.obj