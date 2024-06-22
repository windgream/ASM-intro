assume cs:code
code segment
    s1        db   '1) reset pc$'
    s2        db   '2) start system$'
    s3        db   '3) clock$'
    s4        db   '4) set clock$'
    str       dw   s1,s2,s3,s4                        ;菜单字符串首地址
    row       dw   10,11,12,13                        ;行号
    option    dw   reset,system,clock,setclock        ;功能表
    res       dd   0ffff0000h                         ;重启地址 FFFF:0000
    jos       dd   00007c00h                          ;系统地址 0000:7C00
    cmos      db   9,0,0,8,0,0,7,0,0,4,0,0,2,0,0,0    ;时间对应的CMOS地址
              db   '00/00/00 00:00:00'                ;年/月/日 时:分:秒
    stack     db   128 dup(0)                         ;防止输入过多字符
    signal    db   '/00/00 00:00:'                    ;时间分隔符
    char      dw   charpush,charpop,strshow           ;输入字符串功能表
    top       dw   0                                  ;栈顶指针

    start:    mov  ax,cs
              mov  ds,ax                              ;ds=cs
              mov  ax,0b800h
              mov  es,ax                              ;es=0b800h
              mov  ax,seg stack
              mov  ss,ax
              mov  sp,offset stack+128                ;设置栈

    menu:     call cls
              mov  di,0
              mov  bh,0                               ;页号
              mov  cx,4                               ;4个选项
    showmenu: mov  ah,2                               ;设置光标位置
              mov  dl,30                              ;列号
              mov  dh,row[di]                         ;行号
              int  10h

              mov  dx,str[di]                         ;ds:dx 菜单字符串
              mov  ah,9                               ;显示字符串
              int  21h

              add  di,2
              loop showmenu                           ;下一个字符串

    check:    in   al,60h
              sub  al,2
              cmp  al,3
              ja   check                              ;按下其他键,重新检查
              mov  bl,al
              add  bx,bx
              jmp  option[bx]                         ;按下1~4,跳转

    ;1) reset pc
    reset:    jmp  res                                ;重启

    ;2) start system
    system:   mov  ax,0
              mov  es,ax
              mov  bx,7c00h                           ;es:bx 0000:7c00
              mov  ah,2                               ;读磁盘
              mov  al,1                               ;扇区数,1个
              mov  ch,0                               ;磁道号,0道
              mov  cl,1                               ;扇区号,1扇区
              mov  dh,0                               ;磁头号,0面
              mov  dl,80h                             ;驱动号,80h为硬盘C
              int  13h                                ;将硬盘C的0道0面1扇区读入0000:7c00
              jmp  jos                                ;跳转到0000:7c00

    ;3) clock
    clock:    call cls                                ;清屏
              mov  bl,00000111b                       ;设定颜色初始值

    time:     mov  si,0                               ;si为cmos下标
              mov  cx,6                               ;依次读取年月日时分秒
    gettime:  push cx                                 ;保存cx
              mov  al,cmos[si]
              out  70h,al                             ;写入CMOS地址端口
              in   al,71h                             ;读取CMOS数据端口
              mov  ah,al
              mov  cl,4
              shr  al,cl                              ;al=十位BCD码
              and  ah,0fh                             ;ah=个位BCD码
              add  ax,3030h                           ;BCD码转ASCII码
              mov  cmos[si+16],ax                     ;写入时间字符串
              add  si,3
              pop  cx                                 ;恢复cx
              loop gettime

              mov  si,offset cmos+16                  ;ds:si 时间字符串
              mov  di,160*12+30*2                     ;es:di 显示缓冲区
              mov  cx,17
    showtime: mov  al,[si]                            ;al=字符
              mov  ah,bl                              ;ah=颜色
              mov  es:[di],ax
              add  di,2
              inc  si
              loop showtime

              in   al,60h
              cmp  al,01h                             ;检查 ESC 按下
              je   exit                               ;按下 ESC,退出
              cmp  al,3bh                             ;检查 F1 按下
              jne  time                               ;非F1,继续显示时间
    F1:       in   al,60h
              cmp  al,0bbh                            ;检查 F1 松开
              jne  F1                                 ;没松,继续检查
              inc  bl                                 ;松了,改变颜色
              jmp  time                               ;继续显示时间

    exit:     jmp  menu

    ;4) set clock
    setclock: call cls                                ;清屏
              mov  top,0                              ;栈顶指针清零
              mov  si,offset cmos+16                  ;ds:si 时间字符串

    getchar:  mov  ah,0
              int  16h
              cmp  ah,0eh                             ;backspace
              je   backspace
              cmp  ah,1ch                             ;enter
              je   enter
              mov  ah,0                               ;0号功能
              call charstack                          ;字符入栈
              mov  ah,2                               ;2号功能
              call charstack                          ;显示栈中字符
              jmp  getchar                            ;读取下一个字符

    backspace:mov  ah,1                               ;1号功能
              call charstack                          ;字符出栈
              mov  ah,2                               ;2号功能
              call charstack                          ;显示栈中字符
              jmp  getchar                            ;读取下一个字符

    enter:    call outtime                            ;修改时间
              jmp  menu

    charstack:cmp  ah,2                               ;检查 ah 是否有效
              ja   sret                               ;大于2,返回
              mov  bl,ah
              mov  bh,0
              add  bx,bx
              jmp  char[bx]                           ;0:push,1:pop,2:show

    charpush: mov  bx,top
              mov  [si][bx],al                        ;al=入栈字符
              inc  top
              ret                                     ;入栈成功,返回

    charpop:  cmp  top,0                              ;检查栈是否为空
              je   sret                               ;栈空,返回
              dec  top
              ret                                     ;出栈成功,返回

    strshow:  mov  di,160*12+30*2                     ;es:di 显示缓冲区
              mov  bx,0
    charshow: cmp  bx,top                             ;检查是否显示完毕
              jne  noempty                            ;非空,继续显示
              mov  byte ptr es:[di],' '
              jmp  sret
    noempty:  mov  al,[si][bx]
              mov  es:[di],al
              mov  byte ptr es:[di+2],' '             ;显示结束
              inc  bx
              add  di,2
              jmp  charshow
    sret:     ret

    ;时间字符串写入 CMOS
    outtime:  mov  si,0
              mov  cx,6
    ctime:    push cx
              mov  al,cmos[si]
              out  70h,al                             ;写入CMOS地址端口
              mov  ax,cmos[si+16]                     ;读取输入的时间
              sub  ax,3030h                           ;字符转换为BCD码
              mov  cl,4
              shl  ah,cl                              ;ah高四位=十位BCD码
              or   al,ah                              ;十位和个位合并
              out  71h,al                             ;写入CMOS数据端口
              mov  al,signal[si]
              mov  cmos[si+18],al                     ;防止分隔符被修改
              add  si,3
              pop  cx
              loop ctime
              ret

    cls:      mov  ax,3                               ;重置显示模式为 80x25 彩色
              int  10h
              ret
code ends
end start