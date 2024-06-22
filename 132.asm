assume cs:code

stack segment
	      dw 8 dup (0)
stack ends

code segment
	start: mov  ax,cs
	       mov  ds,ax
	       mov  si,offset lp              	;ds:si指向lp
	       mov  ax,0
	       mov  es,ax
	       mov  di,200h                   	;es:di指向0:200h
	       mov  cx,offset lp_end-offset lp
	       cld
	       rep  movsb                     	;将lp的指令复制到200h处

	       mov  ax,0
	       mov  es,ax
	       mov  word ptr es:[7ch*4],200h
	       mov  word ptr es:[7ch*4+2],0   	;设置中断向量

	       mov  ax,4c00h
	       int  21h
	
	;输入:(cx)=循环次数,(bx)=偏移量
	lp:    push bp
	       mov  bp,sp
	       dec  cx
	       jcxz lp_ret
	       add  [bp+2],bx
	lp_ret:pop  bp
	       iret

	lp_end:nop
code ends
end start