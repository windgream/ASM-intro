assume cs:code,ss:stack,ds:data

stack segment
    dw 0,0,0,0,0,0,0,0
stack ends

data segment
    db '1. display      '
    db '2. brows        '
    db '3. replace      '
    db '4. modify       '
data ends

code segment
start:  mov ax,stack
        mov ss,ax
        mov sp,16

        mov ax,data
        mov ds,ax
        
        mov bx,3
        mov cx,4

s0:     push cx
        mov si,0
        mov cx,4

s:      mov al,[bx+si]
        and al,11011111b
        mov [bx+si],al
        inc si
        loop s

        add bx,16
        pop cx
        loop s0

        mov ax,4c00h
        int 21h
code ends

end start