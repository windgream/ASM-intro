assume cs:codesg

data segment

    db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
    db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
    db '1993','1994','1995'
    ;21年的21个字符串

    dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
    dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
    ;21个dword型数据公司总收入

    dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
    dw 11542,14430,15257,17800
    ;21个word型数据

data ends

table segment

    db 21 dup('year summ ne ?? ')

table ends

codesg segment

start:  mov ax,data
        mov ds,ax

        mov ax,table
        mov es,ax
        
        mov bx,0
        mov si,0
        mov di,168
        mov cx,21

s:      mov ax,[si]
        mov es:[bx].0,ax
        mov ax,[si+2]
        mov es:[bx].2,ax
        ;复制年份

        mov ax,[si+84]
        mov es:[bx].5,ax
        mov dx,[si+86]
        mov es:[bx].7,dx
        ;复制收入

        div word ptr [di]
        mov es:[bx].13,ax
        ;计算人均收入

        mov ax,[di]
        mov es:[bx].10,ax
        ;复制雇员数

        add di,2
        add si,4
        add bx,16        
        loop s
        ;下标指向下一年数据

        mov ax,4c00h
        int 21h

codesg ends

end start