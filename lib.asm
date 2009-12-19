;=========================
;turns a dword into it's ascii equivelent, e.g. 12 to '12'
;then prints it in a MessageBox
PrintNumber:
  push ebp
  mov ebp, esp    
  
  push dword [ebp+8]
  push dword buffer
  call Itoa
  
  push dword MB_OK
  push dword title
  push dword buffer
  push byte 0x0
  call [MessageBoxA]
    
  ret 4
    
;=========================
;[ebp+8]        = Destination buffer
;[ebp+12]       = Number
Itoa:
  push ebp
  mov ebp, esp
  sub esp, 64    ;64 because... just because :)
  
  pusha
  
  ;we put a "null" in ebp, then point
  ;esi to ebp-1, then every number we get, we
  ;convert it to an ascii character, then
  ;we put it into esi, then decrement esi. So
  ;our memory looks like this if we have number
  ;15 passed to this function:
  ;start:  -64 [                         ] 0
  ;null:   -64 [                      [0]] 0
  ;1st#:   -64 [                  [53][0]] 0
  ;2nd#:   -64 [              [49][53][0]] 0
  ;so now esi points to ebp-2, and now is passed
  ;copied to the destination buffer
  mov byte [ebp], 0x0
  mov esi, ebp
  sub esi, 0x1
  
  ;our number
  mov dword eax, [ebp+12]
  
  ;number count +2 (for copying)
  ;it's plus 2 because the last increment does not
  ;get incremented since it does a jump to .End, and
  ;we want to copy the null(0x0). So +2
  mov ecx, 0x2
  .Loop
    xor edx, edx        ;make sure this is 0 if we're dividing(it's a segment)
    mov dword ebx, 10   ;we are going to divide by ten to get each number
    div ebx             ;divide edx:eax by ebx, put qotient in eax and remainder in edx
    mov bl, 48          ;we only need a byte, move '0'(48) to bl
    add bl, dl          ;add our remainder to bl
    mov byte [esi], bl  ;put our byte into esi
    cmp eax, 0x0        ;is there no more numbers?
    je .End             ;no more
    dec esi             ;put esi to next slot
    inc ecx
    jmp .Loop           ;do it again
  
  .End
    ;copy to destination buffer
    mov edi, [ebp+8]
    rep movsb
    
    popa
    
    add esp, 64
    pop ebp
    ret 8
    
;=========================
;[ebp+8]     = String
Atoi:
  push ebp
  mov ebp, esp
  sub esp, 0x4
  
  push esi
  
  ;move esi to the last character
  mov esi, [ebp+8]
  push dword esi
  call Strlen
  add esi, eax
  sub esi, 0x1
    
  mov dword [ebp-4], 0x0 ;our final number
  mov ecx, 0x1 ;our multiplier
  mov ebx, eax ;count down
  std          ;reverse
  .Loop:
    ;the end?
    cmp ebx, 0x0
    je .End
    
    lodsb
    
    mov ah, 0x0
    sub eax, 0x30  ;substract by ascii '0'
    imul eax, ecx 
    add [ebp-4], eax
    
    ;multiply ecx by 10 (to get to the next decimal place)
    imul ecx, 10
    
    dec ebx
    jmp .Loop

  .End:    
    mov dword eax, [ebp-4]
    
    pop esi
  
    add esp, 0x4
    pop ebp
    ret 4
    
;=========================
;[ebp+8]     = String
Strlen:
  push ebp
  mov ebp, esp
    
  push esi
  push ecx
  
  mov esi, [ebp+8]
  xor ecx, ecx
  .Loop:
    lodsb
    cmp al, 0x0
    je .End
    inc ecx
    jmp .Loop
    
  .End:
    mov eax, ecx
    
    pop ecx
    pop esi
    
    pop ebp
    ret 4

;=========================
;[ebp+8]     = Destination
;[ebp+12]    = Source
Strcpy:
  push ebp
  mov ebp, esp
  
  push esi
  push edi
  
  mov esi, [ebp+12]
  mov edi, [ebp+8]
  
  .Loop:
    lodsb
    cmp al, 0x0
    je .End
    stosb
    jmp .Loop
    
  .End:
    stosb
    
    pop edi
    pop esi
    
    pop ebp
    ret 8
    
;=========================
;[ebp+8]     = Destination
;[ebp+12]    = Source
Strcat:
  push ebp
  mov ebp, esp
  
  push edi
  
  mov edi, [ebp+8]  
  push dword edi
  call Strlen
  add edi, eax
  
  push dword [ebp+12]
  push dword edi
  call Strcpy
  
  pop edi

  pop ebp
  ret 8
