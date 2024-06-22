assume cs:code

stack segment
	      dw 8 dup (0)
stack ends


code segment

	start:mov  ax,stack
	      mov  ss,ax
	      mov  sp,16
	
	      mov  ax,4240h
	      mov  dx,000fh
	      mov  cx,0ah
	      call divdw
		
	      mov  ax,4c00h
	      int  21h

	divdw:
	      push ax
	      mov  ax,dx   	;ax=dx
	      div  cl      	;al=商(dx/cx),ah=余数(dx/cx)
	      mov  bl,al   	;bl=商(dx/cx)
	      mov  dl,ah
	      mov  dh,0    	;余数(dx/cx)*65536
	      pop  ax
	      div  cx      	;ax=[余数(dx/cx)*65536+ax]/cx
	      mov  cx,dx   	;cx=余数
	      mov  dl,bl
	      mov  dh,0    	;dx=高16位
	      ret
	;商(dx/cx)*65536+[余数(dx/cx)*65536+ax]/cx

code ends

end start