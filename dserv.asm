%define DEBUG 0
%define commandSize 2048

%include "dserv.inc"

;PROBLEMS:
;exits when calling PrintNumber then closing the socket (when debug is on)

;------------------------;
;Text
;------------------------;
segment .code USE32

global ..start

%include "lib.asm"
%include "Socket.asm"
%include "Command.asm"

;=========================
..start:  
  jmp .ISLoop
  .ISRetry:
    push dword 4000
    call [Sleep]
  .ISLoop:
    call InitiateSockets
    cmp eax, 0x0
    je .ISRetry
  
  ;accept connections
  call ConnectionHandler
  
  ;cleanup sockets
  call Cleanup
  
  push 0x0
  call [ExitProcess]
  
