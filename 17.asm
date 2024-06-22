assume cs:code
code segment
	start:     mov  ax,cs
	           mov  ds,ax
	           mov  si,offset int7ch
	           mov  ax,0
	           mov  es,ax
	           mov  di,200h
	           mov  cx,offset int7ch_end-offset int7ch
	           cld
	           rep  movsb                             	;复制中断服务程序

	           mov  ax,0
	           mov  es,ax
	           mov  word ptr es:[7ch*4],200h
	           mov  word ptr es:[7ch*4+2],0           	;设置中断向量

	           mov  ax,4c00h
	           int  21h

	;输入:ax=0读,1写,dx=逻辑扇区号,es:bx指向内存
	int7ch:    push ax
	           push bx

	           mov  ax,dx
	           mov  dx,0
	           mov  bx,1440
	           div  bx                                	;ax=商(逻辑扇区号/1440),dx=余(逻辑扇区号/1440)
	           mov  bl,al                             	;bl=商(逻辑扇区号/1440)
	           mov  ax,dx                             	;ax=余(逻辑扇区号/1440)
	           mov  dh,bl                             	;dh=商(逻辑扇区号/1440)           面号
	           mov  dl,18
	           div  dl                                	;ah=余(余(逻辑扇区号/1440)/18),al=商(余(逻辑扇区号/1440)/18)
	           mov  ch,al                             	;ch=商(余(逻辑扇区号/1440)/18)    磁道号
	           mov  cl,ah                             	;cl=余(余(逻辑扇区号/1440)/18)
	           add  cl,1                              	;cl=余(余(逻辑扇区号/1440)/18)+1  扇区号

	           pop  bx
	           pop  ax

	           add  ah,2                              	;2读,3写
	           mov  al,1                              	;读写的扇区数
	           mov  dl,0                              	;驱动器号
	           sti
	           int  13h
	           cli
	           iret

	int7ch_end:nop
code ends
end start