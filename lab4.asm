.model tiny
org 100h
.data

maxsiz equ 24 + 1
EOT equ 13

strfind db maxsiz
strfindL db 0
strfind2 db maxsiz dup (0)

strrepl db maxsiz
strreplL db 0
strrepl2 db maxsiz dup (0)

strtext db 255
strtextL db 0
strtext2 db 255 dup (0)

outtext db 512 dup (0)

sfindL dw 0
sreplL dw 0

mfind db 13,10,"Enter word1 to find>$"
mrepl db 13,10,"Enter the word to which the word1 will be changed>$"
mtext db 13,10,"Enter your text>$"
crlf db 13,10,"$"

.code


print macro txt
    mov dx, offset txt
    mov ah, 9
    int 21h
endm

input macro buf
    mov dx, offset buf
    mov ah, 10
    int 21h
endm

start:
    jmp beg

beg:
    mov ax, cs
    mov ds, ax
    mov es, ax

    print mfind
    input strfind
    cmp strfindL, 0
    jz exit
    mov al, strfindL
    mov ah, 0
    mov sfindL, ax

    print mrepl
    input strrepl
    cmp strreplL, 0
    jz exit
    mov al, strreplL
    mov ah, 0
    mov sreplL, ax

    print mtext
    input strtext
    cmp strtextL, 0
    jz exit

    cld
    mov si, offset strtext2
    mov di, offset outtext

m0:
    lodsb
    stosb
    cmp al, EOT
    jz outprint
    call find
    jnz m0
    call replace
    jmp m0

outprint:
    print crlf
    mov si, offset outtext

m1:
    lodsb
    cmp al, EOT
    jz exit
    mov dl, al
    mov ah, 2
    int 21h
    jmp m1

exit:
    mov ax, 4C00h
    int 21h

find:
    push si
    push di
    mov cx, sfindL
    sub si, cx
    cmp si, offset strtext2
    jc return_no
    mov di, offset strfind2
    repe cmpsb
    pop di
    pop si
    ret

return_no:
    mov dl, 1
    or dl, dl
    pop di
    pop si
    ret

replace:
    push si
    sub di, sfindL
    mov cx, sreplL
    mov si, offset strrepl2
    rep movsb
    pop si
    ret
end start
