section .data
inputBuf:
    db 0x9F,0x83,0x6A,0x88,0xDE,0x9A,0xC3,0x54,0x9A
    ;db 0x83,0x6A,0x88,0xDE,0x9A,0xC3,0x54,0x9A
section .bss
outputBuf:
    resb 80


section .text
global _start
_start:
  ;sub esp, 2;
  xor eax, eax; zero out eax
  xor ecx, ecx ; index counter
  mov cx, word 0x08; 8 bytes of 2 chars, 16 total characters!
  mov al, [inputBuf] ; moves inputBuf into lowest byte of eax (al), so eax = 0x83
  ;shl eax, 8 ; move right 8 bits, so now 0x8300
  ;mov al, [inputBuf] ; now 0x8383
  ;and ax, 0x0FF0 ;  now 0x0380, al = x80
  and al, 0xF0 ; 0x80
  shr al, 4 ;0x08 
  
  ;push al
  sub esp, 2;
  
  mov [esp], ax;
  mov [esp+1], byte 0x0;
  
  cmp al, 0x0A ; if its geater than or equal to 0x0A, its a letter in hex so go to islet
  jae islet 
  ;else, go to isnum
isnum:
  ;or [esp], byte 0x30;
  add [esp], byte 0x30
  ;mov [esp], byte 0x6c
  jmp printer

islet:
  sub [esp], byte 0x0A; diff subtract A, so difference + 0x41 = letter!
  add [esp], byte 0x41;
  ;mov [esp], byte 0x21

  jmp printer
printer:
  
  ;add esp, 2 
  ;mov [esp+1], [inputBuf+1]
  ;sub esp, 8;
  ;mov [esp], byte 0x57   ; W
  ;mov [esp+1], byte 0x69 ; i
  ;mov [esp+2], byte 0x6c ; l
  ;mov [esp+3], byte 0x6c ; l
  ;mov [esp+4], byte 0x20 ; " "
  ;mov [esp+5], byte 0x21 ; !
  ;mov [esp+6], byte 0x0A ; \n
  ;mov [esp+7], byte 0x0  ; \0
  
  ;add esp, 2

  mov eax, 4 ; write syscall
  mov ebx, 1 ; important to print... website says "write to STDOUT file"
; mov ecx, ; put text to write

  lea ecx, [esp]
  mov edx, 2; 7 will ! + \0 characters to print

  int 0x80 ; = 80h = 128 = 0o200, all synonyms
  
  add esp, 2

  mov eax, 1
  mov ebx, 0
  int 0x80 ; exit program
