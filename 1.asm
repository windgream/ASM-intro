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
     ;21个word型数据雇员数
data ends

table segment
           db 21 dup('year summ ne ?? ')
table ends

stack segment
           dw 32 dup (0)
stack ends

codesg segment
     start:        mov  ax,stack
                   mov  ss,ax
                   mov  sp,64                ;设置栈段

                   mov  ax,table
                   mov  ds,ax                ;ds:di 指向 table
                   call crtate_table         ;创建 table

                   mov  ax,0b800h
                   mov  es,ax                ;es:[bx][si] 指向显示缓冲区
                   call clear_screen         ;清屏

                   mov  cx,21                ;输出 21 年的数据
                   mov  bx,160               ;bx 索引显示缓冲区的行
                   mov  di,0                 ;di 索引 table 表中的每一个数据

     line:         push cx                   ;保存外层循环
                   mov  cx,4                 ;年份占 4 个字符
                   mov  si,0                 ;si 索引显示缓冲区的列

     year:         mov  al,[di]              ;di=xxx0h~xxx3h
                   inc  di
                   mov  es:[bx][si],al       ;显示年份
                   inc  si
                   mov  al,0fh
                   mov  es:[bx][si],al       ;设置颜色
                   inc  si
                   loop year

                   inc  di
                   mov  ax,[di]              ;di=xxx5h
                   add  di,2
                   mov  dx,[di]              ;di=xxx7h
                   mov  si,20
                   call dtoc_and_show        ;显示收入


                   add  di,3
                   mov  ax,[di]              ;di=xxxah
                   mov  dx,0
                   mov  si,40
                   call dtoc_and_show        ;显示雇员数

                   add  di,3
                   mov  ax,[di]              ;di=xxxch
                   mov  dx,0
                   mov  si,60
                   call dtoc_and_show        ;显示人均收入

                   add  di,3                 ;di=xxx0h
                   add  bx,160               ;bx 指向下一行
                   pop  cx                   ;恢复外层循环
                   loop line                 ;输出下一行数据

                   mov  ax,4c00h
                   int  21h                  ;程序返回


     crtate_table: mov  ax,data
                   mov  es,ax                ;es指向 data 段

                   mov  bx,0                 ;ds:bx.idata指向table
                   mov  si,0
                   mov  di,168               ;es:di指向雇员数
                   mov  cx,21

     table_line:   mov  ax,es:[si]
                   mov  [bx].0,ax
                   mov  ax,es:[si].2
                   mov  [bx].2,ax            ;复制年份

                   mov  ax,es:[si].84
                   mov  [bx].5,ax
                   mov  dx,es:[si].86
                   mov  [bx].7,dx            ;复制收入

                   div  word ptr es:[di]     ;计算人均收入
                   mov  [bx].13,ax           ;复制人均收入

                   mov  ax,es:[di]
                   mov  [bx].10,ax           ;复制雇员数

                   add  di,2
                   add  si,4
                   add  bx,16
                   loop table_line           ;复制下一行数据
                   ret

     ;将dwrod型数据转换为十进制字符串,输出在显示缓冲区中
     ;ax=低16位,dx=高16位
     ;es:bx+si指向字符串首地址
     dtoc_and_show:push ax
                   push cx
                   push dx
                   push bp                   ;保存用到的寄存器
                   mov  bp,0                 ;bp用于计算余数的个数

     pushnum:      mov  cx,10
                   call divdw
                   push cx
                   inc  bp                   ;余数个数+1
                   mov  cx,ax
                   add  cx,dx
                   jcxz show
                   jmp  pushnum              ;将每一位数字依次入栈

     show:         mov  cx,bp                ;输出所有余数

     popnum:       pop  ax
                   add  ax,30h
                   mov  es:[bx][si],al       ;显示数据
                   inc  si

                   mov  al,0fh
                   mov  es:[bx][si],al       ;设定颜色
                   inc  si
                   loop popnum

                   pop  bp
                   pop  dx
                   pop  cx
                   pop  ax                   ;恢复用到的寄存器
                   ret

     ;输入:dx 被除数高16位,ax 被除数低16位,cx 除数
     ;输出:dx 商高16位,ax 商低16位,cx 余数
     ;公式:商=商(dx/cx)*65536+[余数(dx/cx)*65536+ax]/cx
     divdw:        push bx                   ;保存bx

                   push ax                   ;保存ax
                   mov  ax,dx                ;ax=dx
                   mov  dx,0
                   div  cx                   ;ax=商(dx/cx),dx=余数(dx/cx)
                   mov  bx,ax                ;bx=商(dx/cx)
                   pop  ax                   ;恢复ax
                   div  cx                   ;ax=[余数(dx/cx)*65536+ax]/cx
                   mov  cx,dx                ;cx=余数
                   mov  dx,bx                ;dx=商(dx/cx)

                   pop  bx                   ;恢复bx
                   ret


     clear_screen: 
     ;清屏
                   mov  si,0
                   mov  ax,0
                   mov  cx,2000              ;将80*25显示缓冲区全部置为0

     clear:        mov  es:[si],ax
                   add  si,2
                   loop clear
                   ret
codesg ends

end start