assume cs:codesg

data segment

            db 'welcome to masm!'       ;目标字符串，占16字节
            db 02h,24h,71h

data ends

stack segment

             dw 8 dup (0)       ;定义16字节的栈段

stack ends

codesg segment

       start: mov  ax,data
              mov  ds,ax            ;ds作为字符串和字符串属性的段地址
              mov  ax,0b800h
              mov  es,ax            ;es作为显示缓冲区段地址
              mov  ax,stack
              mov  ss,ax            ;栈用于保存cx
              mov  sp,16

              mov  si,0
              mov  bx,0
              mov  cx,2000          ;将显示缓冲区全部置为0

       s1:    mov  es:[si],bx
              add  si,2
              loop s1               ;清屏

              mov  si,06e0h
              add  si,64            ;es:si指向显示缓冲区的中间
              mov  di,16            ;ds:di指向字符串属性
              mov  cx,3             ;复制 3 行字符串

       s0:    push cx               ;保存外层循环次数
              mov  bx,0             ;ds:bx指向字符串
              mov  cx,16            ;字符串中共 16 个字符

       s:     mov  al,[bx]
              mov  es:[si],al       ;复制字符
              inc  si               ;es:si指向属性

              mov  al,[di]
              mov  es:[si],al       ;复制属性
              inc  si               ;es:si指向下一个字符

              inc  bx               ;指向字符串中下一个字符
              loop s                ;复制下一个字符及属性

              add  si,128           ;es:si指向显示缓冲区的下一行,160-32=128
              inc  di               ;ds:di指向下一行字符串的属性
              pop  cx               ;恢复外层循环次数
              loop s0               ;复制下一行字符及属性

              mov  ax,4c00h
              int  21h

codesg ends

end start