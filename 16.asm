assume cs:code
code segment
	start:  mov  ax,cs
	        mov  ds,ax
	        mov  si,offset setscreen
	        mov  ax,0
	        mov  es,ax
	        mov  di,200h
	        mov  cx,offset sts_end-offset sts
	        cld
	        rep  movsb                       	;将show_end-show的指令复制到200h处

	        mov  ax,0
	        mov  es,ax
	        mov  word ptr es:[7ch*4],200h
	        mov  word ptr es:[7ch*4+2],0     	;设置中断向量

	        mov  ax,4c00h
	        int  21h


	sts:    cmp  ah,0
	        je   jmp1
	        cmp  ah,1
	        je   jmp2
	        cmp  ah,2
	        je   jmp3
	        cmp  ah,3
	        je   jmp4
	        iret

	jmp1:   jmp  sub1
	jmp2:   jmp  sub2
	jmp3:   jmp  sub3
	jmp4:   jmp  sub4                        	;此处跳转最好使用偏移地址


	sub1:   push bx
	        push cx
	        push es
	        mov  bx,0b800h
	        mov  es,bx
	        mov  bx,0
	        mov  cx,2000
	sub1s:  mov  byte ptr es:[bx],' '
	        add  bx,2
	        loop sub1s
	        pop  es
	        pop  cx
	        pop  bx
	        iret

	sub2:   push bx
	        push cx
	        push es
	        mov  bx,0b800h
	        mov  es,bx
	        mov  bx,1
	        mov  cx,2000
	sub2s:  and  byte ptr es:[bx],11111000b
	        or   es:[bx],al
	        add  bx,2
	        loop sub2s
	        pop  es
	        pop  cx
	        pop  bx
	        iret


	sub3:   push bx
	        push cx
	        push es
	        mov  cl,4
	        shl  al,cl
	        mov  bx,0b800h
	        mov  es,bx
	        mov  bx,1
	        mov  cx,2000
	sub3s:  and  byte ptr es:[bx],10001111b
	        or   es:[bx],al
	        add  bx,2
	        loop sub3s
	        pop  es
	        pop  cx
	        pop  bx
	        iret


	sub4:   push cx
	        push si
	        push di
	        push es
	        push ds
	        mov  si,0b800h
	        mov  es,si
	        mov  ds,si
	        mov  si,160                      	;ds:si 指向第 n+1 行
	        mov  di,0                        	;es:di 指向第 n 行
	        cld
	        mov  cx,24                       	;共复制 24 行

	sub4s:  push cx
	        mov  cx,160
	        rep  movsb                       	;复制
	        pop  cx
	        loop sub4s

	        mov  cx,80
	        mov  si,0
	sub4s1: mov  byte ptr[160*24+si]," "     	;最后一行清空
	        add  si,2
	        loop sub4s1

	        pop  ds
	        pop  es
	        pop  di
	        pop  si
	        pop  cx
	        iret
	sts_end:nop
code ends
end start