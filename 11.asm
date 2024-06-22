assume cs:code

data segment
	     db "Beginner's All-purpose Symbolic Instruction Code.",0
data ends

stack segment
	      db 64 dup(0)
stack ends

code segment
	begin:        mov  ax,0b800h
	              mov  es,ax        	;es:di指向显示缓冲区
	              call cls          	;清屏

	              mov  ax,stack
	              mov  ss,ax
	              mov  sp,64

	              mov  ax,data
	              mov  ds,ax
	              mov  si,0         	;ds:si指向字符串
	              call letterc

	              mov  dh,3         	;行号
	              mov  dl,8         	;列
	              mov  cl,2         	;颜色
	              call show_str     	;显示字符串

	              mov  ax,4c00h
	              int  21h

 
	;将以 0 结尾的字符串中的小写字母转换为大写字母
	;输入：ds:si 指向字符串
	letterc:      push si
	              push ax
	
	letterc_begin:mov  al,[si]
	              cmp  al,0
	              je   letterc_end
	              cmp  al,'a'
	              jb   letterc_next
	              cmp  al,'z'
	              ja   letterc_next
	              sub  al,20h
	              mov  [si],al

	letterc_next: inc  si
	              jmp  letterc_begin

	letterc_end:  pop  ax
	              pop  si
	              ret

	;输入:行号dh,列号dl,颜色cl,ds:si指向字符串首地址, 0截止
	show_str:     mov  al,dh
	              mov  ah,0
	              mov  bl,160
	              mul  bl           	;ax=dh*160
	              mov  bl,dl
	              mov  bh,0
	              add  bx,bx        	;bx=dl*2
	              add  ax,bx        	;ax=dh*160+dl*2
	              mov  di,ax        	;di=dh*160+dl*2

	show_s:       mov  al,[si]
	              cmp  al,0
	              je   show_over    	;0 为结束符
	              inc  si           	;指向字符串下一个字符
	              mov  es:[di],al   	;复制字符
	              inc  di           	;指向属性
	              mov  es:[di],cl   	;复制属性
	              inc  di           	;指向缓冲区下一个字符
	              jmp  show_s
	show_over:    ret


	;清屏
	cls:          push di
	              push ax
	              push cx

	              mov  di,0
	              mov  ax,0
	              mov  cx,2000      	;将80*25显示缓冲区全部置为0

	clear:        mov  es:[di],ax
	              add  di,2
	              loop clear

	              pop  cx
	              pop  ax
	              pop  di
	              ret
code ends

end begin