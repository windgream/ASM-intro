assume cs:codesg

stack segment
              db 128 dup(0)
stack ends

codesg segment
        start:   mov   ax,stack
                 mov   ss,ax
                 mov   sp,128

                 mov   ax,cs
                 mov   ds,ax

                 mov   ax,0
                 mov   es,ax

                 mov   si,offset int9
                 mov   di,204h
                 mov   cx,offset int9_end-offset int9
                 cld
                 rep   movsb                                 ;复制 int9 的中断处理程序到 200h 处

                 push  es:[9*4]
                 pop   es:[200h]
                 push  es:[9*4+2]
                 pop   es:[202h]                             ;保存原来的中断向量

                 cli
                 mov   word ptr es:[9*4],204h
                 mov   word ptr es:[9*4+2],0                 ;设置中断向量
                 sti

                 mov   ax,4c00h
                 int   21h


        ;按下'A'键后，一旦松开，显示满屏幕的'A'


        int9:    push  ax
                 push  bx
                 push  cx
                 push  es

                 in    al,60h

                 pushf
                 call  dword ptr cs:[200h]

                 cmp   al,1eh                                ;a键的扫描码通码是1eh
                 jne   int9ret

        break:   in    al,60h
                 cmp   al,9eh                                ;a键的扫描码断码是9eh
                 jne   break

                 mov   ax,0b800h
                 mov   es,ax
                 mov   bx,0
                 mov   ah,'A'
                 mov   cx,2000
        s:       mov   es:[bx],ah
                 add   bx,2
                 loop  s

        int9ret: pop   es
                 pop   cx
                 pop   bx
                 pop   ax
                 iret
        int9_end:nop
codesg ends
end start