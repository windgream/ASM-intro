assume cs:code

data segment

	     db 16 dup (0)

data ends

stack segment

	      dw 8 dup (0)

stack ends

code segment

	start:       mov  ax,data
	             mov  ds,ax       	;ds:si指向字符串首地址

	             mov  ax,stack
	             mov  ss,ax
	             mov  sp,16

	             mov  ax,12666
	             mov  dx,0
	             mov  si,0
	             call dtoc
		
	             mov  dh,8
	             mov  dl,3
	             mov  cl,2
	             mov  di,0
	             call show_str

	             mov  ax,4c00h
	             int  21h


	dtoc:        
	;将dwrod型数据转换为十进制字符串
	;ax=dword型数据低16位
	;dx=dword型数据高16位
	;ds:si指向字符串首地址
	             push cx
	             push ax
	             push dx
	             push si
	             push bp          	;保存用到的寄存器
	             mov  bp,0        	;bp用于计算余数的个数

	sdtoc:       mov  cx,10
	             call divdw
	             push cx
	             inc  bp          	;余数个数+1
	             mov  cx,ax
	             add  cx,dx
	             jcxz show
	             jmp  sdtoc       	;将每一位数字依次入栈

	show:        mov  cx,bp       	;输出所有余数

	number:      pop  ax
	             add  ax,30h
	             mov  [si],al
	             inc  si
	             loop number

	             pop  bp
	             pop  si
	             pop  dx
	             pop  ax
	             pop  cx          	;恢复用到的寄存器
	             ret



	;输入:行号dh,列号dl,颜色cl,ds:si指向字符串首地址, 0截止
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
	             jcxz oks         	;检查是否为0，为0则结束
	             inc  si          	;指向字符串下一个字符
	             mov  es:[di],cl  	;复制字符
	             inc  di          	;指向属性
	             mov  es:[di],bl  	;复制属性
	             inc  di          	;指向缓冲区下一个字符
	             loop s
	oks:         ret

	divdw:       
	;输入:dx 被除数高16位,ax 被除数低16位,cx 除数
	;输出:dx 商高16位,ax 商低16位,cx 余数
	;公式:商=商(dx/cx)*65536+[余数(dx/cx)*65536+ax]/cx
	;输出:dx=商(dx/cx)*65536,ax=[余数(dx/cx)*65536+ax]/cx
	             push bx          	;保存bx

	             push ax          	;保存ax
	             mov  ax,dx       	;ax=dx
	             mov  dx,0
	             div  cx          	;ax=商(dx/cx),dx=余数(dx/cx)
	             mov  bx,ax       	;bx=商(dx/cx)
	             pop  ax          	;恢复ax
	             div  cx          	;ax=[余数(dx/cx)*65536+ax]/cx
	             mov  cx,dx       	;cx=余数
	             mov  dx,bx       	;dx=商(dx/cx)

	             pop  bx          	;恢复bx
	             ret

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
