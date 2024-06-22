assume cs:code

code segment
      start:jmp  clock
      pos   db   9,8,7,4,2,0               ;时间对应的CMOS地址
            db   'xx/xx/xx xx:xx:xx$'      ;年/月/日 时:分:秒
      clock:mov  ax,data
            mov  ds,ax
            mov  si,0                      ;ds:si指向时间所在地址
            mov  di,6                      ;ds:di指向时间字符串
            mov  cx,6


      s:    push cx                        ;保存cx
            mov  al,pos[si]
            out  70h,al                    ;写入CMOS地址端口
            in   al,71h                    ;从CMOS数据端口读取时间

            mov  ah,al
            mov  cl,4
            shr  al,cl                     ;al=十位
            and  ah,0fh                    ;ah=个位
            add  ax,3030h                  ;转换为ASCII码
            mov  pos[di],ax                ;保存到时间字符串
            add  di,3
            inc  si
            pop  cx                        ;恢复cx
            loop s                         ;依次显示年月日时分秒

            mov  ah,2                      ;设置光标位置
            mov  bh,0                      ;第0页
            mov  dh,12                     ;行
            mov  dl,31                     ;列
            int  10h

            mov  ah,9                      ;显示字符串
            mov  dx,6                      ;ds:dx指向时间字符串
            int  21h

            jmp  start                     ;继续显示时间
            
            mov  ax,4c00h
            int  21h
code ends
end start