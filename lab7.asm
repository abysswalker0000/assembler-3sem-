.model tiny
.code
    org 80h                     
    cmd_length db ?             
    cmd_line db ?               
    org 100h                    
    
start:
    cld
    mov bp,sp
    mov cl,es:[80h]
    mov di,offset cmd_line      
ParametrsGet:                     
    mov al,' '
    repz scasb
    dec di  
    push di
    inc word ptr argc
    mov si,di                   
ParametrsScan:
    lodsb                       
    cmp al,0Dh                  
    je ParametrsEnd
    cmp al,20h                  
    jne ParametrsScan             
    dec si
    mov byte ptr [si],0         
    mov di,si
    inc di
    jmp short ParametrsNext        
ParametrsEnd:
    dec si
    mov byte ptr [si],0         

ParametrsNext:                     
    mov al,' '
    repe scasb
    dec di
    inc word ptr argc
    mov si, di                  
    mov di, offset number
ParametrsScan:
    cmp [si],0Dh                
    je ParametrsEnd
    cmp [si],20h                
    je ParametrsEnd
    movsb
    jmp ParametrsScan
ParametrsEnd:
    mov byte ptr [si],0         
    mov si, offset number
string_to_num:
    xor dx, dx   
    xor cx, cx
    lodsb       
    test al, al 
    jz  ex
    cmp al, '-'
    je  set_negative
    jmp check_digit

set_negative:
    inc cx
    jmp loop_

check_digit:
    cmp al, '9'  
    jnbe loop_
    cmp al, '0'       
    jb  loop_
    sub al, '0' 
    
    push ax
    mov ax, dx
    mov dx, 10
    mul dx
    mov dx, ax
    pop ax 
    add dx, ax  
    jmp loop_  
    
loop_:    
    xor ax,ax
    lodsb       
    test al,al 
    jz  ex
    cmp al,'9'  
    jnbe  loop_
    cmp al,'0'       
    jb    loop_
    sub ax,'0' 
    
    push ax
    mov ax, dx
    mov dx, 10
    mul dx
    mov dx, ax
    pop ax 
    add dx, ax  
    jmp  loop_
    
catch_error:
    mov ah, 09h
    mov dx, offset error
    int 21h
    jmp exit
ex:     

    mov ax,dx   
    mov number, ax
    
    cmp number, 0
    jle catch_error
    
    cmp number, 256
    jge catch_error
    
    mov     bx, ((program_length/16)+1)+256/16+((dsize/16)+1)+256/16
    mov     ah, 4Ah
    int     21h   
    
    xor cx, cx
    mov cx, number
run:
    mov ax,4B00h                        
    mov dx, offset cmd_line+1               
    mov bx, offset env                  
    int 21h 
    loop run
    jmp exit
exit:
    mov ax,4C00h
    int 21h                             

    printString macro out_message
    push ax
    push dx
    mov ah, 09h
    mov dx, offset out_message
    int 21h
    mov dl, 10
    mov ah, 02h
    int 21h
    mov dl, 13
    mov ah, 02h
    int 21h
    pop dx
    pop ax
endm


error db "Incorrect N",  '$'   
env dw 0
dsize = $ - env
number dw 0
argc dw 0
buffer db 0


program_length = $ - start    

end start