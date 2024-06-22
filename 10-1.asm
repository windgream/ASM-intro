assume cs:code

data segment

	     db 'Welcome to masm!',0

data ends


code segment

	start:       mov  dh,8        	;行号
	             mov  dl,3        	;列号
	             mov  cl,2        	;颜色
	             mov  ax,data
	             mov  ds,ax
	             mov  si,0        	;ds:si指向字符串
	             call show_str

	             mov  ax,4c00h
	             int  21h

	show_str:    mov  ax,0b800h
	             mov  es,ax       	;es:di指向显示缓冲区

	             call clear_screen

	             mov  al,dh
	             mov  ah,0
	             mov  bl,160
	             mul  bl          	;ax=dh*160
	             mov  bl,dl
	             mov  bh,0
	             add  bx,bx       	;bx=dl*2
	             add  ax,bx       	;ax=dh*160+dl*2
	             mov  di,ax       	;di=dh*160+dl*2

	             mov  bl,cl       	;颜色改在bl中

	s:           mov  cl,[si]
	             mov  ch,0
	             jcxz ok          	;检查是否为0，为0则结束
	             inc  si          	;指向字符串下一个字符
	             mov  es:[di],cl  	;复制字符
	             inc  di          	;指向属性
	             mov  es:[di],bl  	;复制属性
	             inc  di          	;指向缓冲区下一个字符
	             loop s
	ok:          ret


	clear_screen:
	;清屏
	             push si
	             push ax
	             push cx

	             mov  si,0
	             mov  ax,0
	             mov  cx,2000     	;将80*25显示缓冲区全部置为0

	clear:       mov  es:[si],ax
	             add  si,2
	             loop clear

	             pop  cx
	             pop  ax
	             pop  si
	             ret
code ends

end start