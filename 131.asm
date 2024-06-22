assume cs:code

stack segment
	      dw 8 dup (0)
stack ends

code segment

	start:    mov  ax,cs
	          mov  ds,ax
	          mov  si,offset show
	          mov  ax,0
	          mov  es,ax
	          mov  di,200h
	          mov  cx,offset show_end-offset show
	          cld
	          rep  movsb                         	;将show_end-show的指令复制到200h处

	          mov  ax,0
	          mov  es,ax
	          mov  word ptr es:[7ch*4],200h
	          mov  word ptr es:[7ch*4+2],0       	;设置中断向量

	          mov  ax,4c00h
	          int  21h
	
	;输入:行号dh,列号dl,颜色cl,ds:si指向字符串首地址,0截止
	show:     mov  ax,0b800h
	          mov  es,ax
	          mov  al,dh
	          mov  ah,0
	          mov  bl,160
	          mul  bl                            	;ax=dh*160
	          mov  bl,dl
	          mov  bh,0
	          add  bx,bx                         	;bx=dl*2
	          add  ax,bx                         	;ax=dh*160+dl*2
	          mov  di,ax                         	;di=dh*160+dl*2

	show_s:   mov  al,[si]
	          cmp  al,0
	          je   show_over                     	;0 为结束符
	          inc  si                            	;指向字符串下一个字符
	          mov  es:[di],al                    	;复制字符
	          inc  di                            	;指向属性
	          mov  es:[di],cl                    	;复制属性
	          inc  di                            	;指向缓冲区下一个字符
	          jmp  show_s
	show_over:iret

	show_end: nop
code ends

end start