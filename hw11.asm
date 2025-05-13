; lovingly crafted by will c.
section .data
inputBuf:
    db 0x83,0x6A,0x88,0xDE,0x9A,0xC3,0x54,0x9A
section .bss
outputBuf:
    resb 80


section .text
global _start
_start:
  ;sub esp, 2;
  xor eax, eax; zero out eax
  xor ecx, ecx ; zero out index counter
  xor esi, esi ; clear! set to 0; tracks byte in inputBuf
  xor edi, edi ; clear set to zero; tracks byte in outputBuf
  ; cl will be used to track if we are on the high or low 4 bits of the loop, as each chunk of 2 hex is 4 bytes total

  mov cl, byte 0x0 ; tracks if low 4 bits or high 4 bits (eg 0x83, 8 (high) or 3 (low))
  ;mov cl, byte 0x0 ; tracks which byte (0x83, 0x6A, etc)

loadByte:
  cmp esi, 0x8 ; 8x2 = 16 bytes total. if we hit this 8 times, weve iterated through everything
  ;jae exiter 
  jae printer
  ;push cx
  ;movzx ecx, cl
  mov al, [inputBuf + esi] ; moves inputBuf into lowest byte of eax (al), so eax = 0x83
  ;pop cx
  ;shl eax, 8 ; move right 8 bits, so now 0x8300
  ;mov al, [inputBuf] ; now 0x8383
  ;and ax, 0x0FF0 ;  now 0x0380, al = x80
  ; 0 = top half, so 8, the one to do first!
  cmp cl, 0x00 ; determine if high or low byte
  ;je topHalf
  ;jmp botHalf
  je botHalf
  jmp topHalf
topHalf:
  ;mov ch, 0x00 
  ; zero out the non used value.
  and al, 0xF0 ; 0x80
  ; shift it over to start at the bottom properly
  shr al, 4 ;0x08 

  jmp conv
botHalf:
  ;mov ch, 0x01
  and al, 0x0F
  ;zero out the non used value
  jmp conv
conv:
  ;push al
  ;sub esp, 3;
  ;mov [esp], ax;
  ;mov [esp+2], byte 0x0;
  ; parses if its gonna be a letter or a number
  cmp al, 0x0A ; if its geater than or equal to 0x0A, its a letter in hex so go to islet
  jae islet 
  ;else, go to isnum
  jmp isnum ; just incase...
isnum:
  ;or [esp], byte 0x30;
  ;add [esp], byte 0x30
  ; basic principal here is:
  ; 00110000b = 060 = 0x30 = 0, so add to this
  ; numbers in ascii hex start at 0x30, so by adding 0x30 to the 0x0-9, it will
  ; now be the hex value for the ascii of that initial number
  add al, byte 0x30
  ;mov [esp], byte 0x6c
  jmp insertdata

islet:
  ; A in ascii sits at 0x41.
  ; this means B at 0x42, etc.
  ; by subtracting 0xA from the letter we want, we get the distance from A in ascii table
  ; eg 0xD - 0xA = 3, so we know it needs to be 0x3 + 0x41 (A), which will be 0x44 (D)
  ;sub [esp], byte 0x0A; diff subtract A, so difference + 0x41 = letter!
  ;add [esp], byte 0x41;
  sub al, byte 0x0A ; 
  add al, byte 0x41 ;
  
  ;mov [esp], byte 0x21

  jmp insertdata

insertdata:
  ; determine if we are working on low or high byte. top should come first.
  cmp cl, 0x00
  je topinsert
  jmp botinsert 
topinsert:

  ;and [outputBuf + ecx], [esp] ; moves inputBuf into lowest byte of eax (al), so eax = 0x83
  ; because its a 32 bit system, we will be moving ax into the output buff
  ; so push the converted value into ah temporarily, and then parse the low byte!
  mov ah, al ; its the top half, so slide it to the first 8 bits of ax 
  ;UUand 
  ;shl [outputBuf + ecx], 4
  ;shl [outputBuf + ecx], 4 
  mov cl, byte 0x01 ; look at high byte now !
  ;jmp printer 
  jmp loadByte
botinsert:

  ; ah is top half, al is bot half. push all togather into outputBuf and increment cl!
  ; ax = ah + al! 
  ; increase the byte iterator
  inc esi
  ; push to outputBuf + edi (so how many bytes into outputbuf)
  mov [outputBuf + edi], ax
  add edi, 2
  ; we just added ax, so 4 bytes, so add 2 cause 32 bit system = 8 bytes
  mov [outputBuf + edi], byte 0x20 ; add space to it!
  inc edi ; slide over outputBuf pointer now to after all current bytes, + the 3 new ones total
  ; edi increased by 3 each loop
  ; moves inputBuf into lowest byte of eax (al), so eax = 0x83
  ;pop cx
  mov cl, byte 0x00 ; back to looking at low byte
  xor eax, eax
  ; clear ax!
  ; inc cl  ;move to next bit!
  jmp loadByte
  ;jmp printer
  ; if recall  
printer:
  ; ok big note here, we add a space at the end, so we do edi-1 to put the newline in
  ; that extra space!! dude im kinda cracked at this asm thing teehee
  mov [outputBuf + edi-1], byte 0xA ; newline
  mov [outputBuf + edi], byte 0x0 ; nullterm
  inc edi ; edi should be after the last character in the thing
  ; should be 25 at the end,  
  mov     eax, 4
  mov     ebx, 1
  mov     ecx, outputBuf       ; pointer to the string stack location
  mov     edx, edi        ; remember that edi should now be the number of characters added to the stack, so +25!
  int     0x80  ; interupt
  jmp exiter

; UNUSED CODE BELOW BEFORE REWRITE, DELETE BEFORE SUBMISSION
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
  
  sub esp, 25 ; 16 chars, 7 spaces, newline null term, 
  mov ecx, 8 ; shoud loop 8 times, 2 for each pair
; ok so ebp and esp both work on the stack. esp is stack pointer
; esp often moves around for temp vars and short term stuff
; ebp is the pointer for the current stack frame, local vars for functions referenced by offset to ebp, not esp
; ebp doesnt move when push/pop or add/sub, while esp does
; esi is the source for the copy and edi is the dest for the esi
  mov ebp, esp ; initial offset of 25
  xor esi, esi ; clear! set to 0
  xor edi, edi ; clear set to zero
  mov ecx, 8  ; 8 loops!

  ; basically we have 3 trackers to do this GAH!!
  ; edi is the position we are writing to in the stack
  ; esi is our position in outputBuf
  ;   REMEMBER THESE ARE GOING TO BE DESYNCED CAUSE OF THE SPACES!!
print_loop:
    ; Copy 2 bytes (a word) from outputBuf + esi to stack buffer + edi
    mov     ax, [outputBuf + esi] ; 2 bytes into ax, intermediary
    mov     [ebp + edi], ax       ; move those onto the stack edi (the iterator) bytes
    ; ax onto the [ebp stack pointer + edi dest iterator], ax
    add     esi, 2          ; move src index by 2
    add     edi, 2          ; move dest index by 2 bytes
    dec     ecx             ; decrement the iterator
    jz      .end_print_loop ; exit the loop if its the last pair (when dec, ecx = 0 so zf =0 ,it jumps! 
    ; else
    jmp     print_loop      ; if it didnt break earlier, keep looping
.end_print_loop:
    ; newline and null term at end
    mov     [ebp + edi], byte 0x0A
    inc edi
    mov     [ebp + edi], byte 0x0
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, ebp        ; pointer to the string stack location
    mov     edx, edi        ; remember that edi should now be the number of characters added to the stack, so +25!
    int     0x80  ; interupt

  jmp exiter

  mov [esp], ah
  mov [esp+1], al
  mov [esp+2], byte 0x0
  mov eax, 4 ; write syscall
  mov ebx, 1 ; important to print... website says "write to STDOUT file"
; mov ecx, ; put text to write
  push cx
  lea ecx, [esp]
  mov edx, 3; 2 ascii + null = 3 

  int 0x80 ; = 80h = 128 = 0o200, all synonyms
  pop cx 
  add esp, 3

  jmp loadByte

exiter:
  mov eax, 1
  mov ebx, 0
  int 0x80 ; exit program
