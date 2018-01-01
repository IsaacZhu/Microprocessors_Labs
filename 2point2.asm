;2.1 显示Sample.txt
.MODEL SMALL
.STACK 1024

.DATA
    FILENAME DB 'D:\SOFTWARE\emu8086\emu8086\MyBuild\Sample.txt',0
    FILEHANDLE DW ?
    FILEHI DW ?
    FILELO DW ?
    BUFFSIZE DW ?
    BUFFER DB 2048 DUP(0)
    STRINGBUFFER DB 1024 DUP(0) ;存储转化后的字符串
    RESULT DB 1024 DUP(0)       ;暂存计算结果
    ARRAY DB 1024 DUP(0)        ;存储字符串转化而成的四进制数
    STRINGLENGTH DW 0     
    TX6 DB 3,2,1,2,2,2,2,1,0,0,0,0,0      ;打表：36^5   13位
    TX5 DB 1,2,1,2,2,0,1,0,0,0,0          ;打表：36^4   11位
    TX4 DB 2,3,1,2,1,0,0,0                ;36^3         8位
    TX3 DB 1,1,0,1,0,0                    ;36^2 = 1296  6位
    TX2 DB 2,1,0                          ;36           3位
    TX1 DB 1                              ;1            1位
    BITNUM DW 1
    
.CODE
START:
    CALL PREADFILE          ;把文件内容读到buffer
    JMP TRANSFORM
    
PREADFILE PROC NEAR
;OPEN FILE:OPEN FILE NAMED "FILENAME"
FOPEN:
    mov AX,@DATA
    mov DS,AX
    MOV DX,OFFSET FILENAME  ;OPEN FILE
    MOV AX,3D00H              ;CONTROL
    INT 21H                 ;OPEN FILE
    MOV FILEHANDLE,AX

;COUNT THE SIZE OF FILE
SIZECOUNT:
    CALL MOVFHH
    MOV FILEHI,DX
    MOV FILELO,AX
    CALL MOVFHT
    SUB DX,FILEHI
    MOV FILEHI,DX
    SUB AX,FILELO
    MOV FILELO,AX
    MOV BUFFSIZE,AX
    JMP READFILE
        
;MOVE FILE HANDLE TO HEAD OF FILE
MOVFHH:
    MOV AH,42H
    MOV BX,FILEHANDLE
    MOV AL,0
    MOV CX,0
    MOV DX,0
    INT 21H
    RET

;MOVE FILE HANDLE TO TAIL OF FILE
MOVFHT:
    MOV AH,42H
    MOV BX,FILEHANDLE
    MOV AL,2
    MOV CX,0
    MOV DX,0
    INT 21H
    RET        
 
;READ FILE:COPY NUMBERS INTO ARRAY[]
READFILE:
    CALL MOVFHH
    MOV AH,3FH
    MOV BX,FILEHANDLE
    MOV DX,OFFSET BUFFER
    MOV CX,BUFFSIZE
    INT 21H
    
;CLOSE FILE
CLOSEF:
    MOV AH,3EH
    MOV BX,FILEHANDLE
    INT 21H

ENDOFREADFILE:
    RET
               
PREADFILE ENDP

;显示文件一行
PUTSTRING PROC NEAR
STARTPUTSTRING:
    PUSH AX
    PUSH DI
    LEA DI,STRINGBUFFER
    
PLOOP:
    MOV DL,[DI]
    CMP DL,13          ;结束符是'\n'
    JZ ENDPUTSTRING
    MOV AH,02H
    INT 21H
    ADD DI,1
    JMP PLOOP
    
ENDPUTSTRING:
    POP DI
    POP AX
    RET    
PUTSTRING ENDP

;转化每一行并输出
OUTPUTLOOP1:
    LEA DI,BUFFER
    MOV BX,0
    JMP TRANSFORM
    
OUTPUTLOOP2:
    MOV STRINGLENGTH,BX ;该长度不包含'\n'
    CALL PUTSTRING      ;输出转化后的字符串
    CALL SYSCONVERT     ;进制转化
    JMP OUTPUTLOOP1     ;继续循环，读下一行
    JMP LEAVE
    
    
;将字符串按格式转化
TRANSFORM:     
    LEA SI,STRINGBUFFER
    
TLOOP:
    MOV AL,[DI]
    ADD DI,1
    CMP AL,13       ;看是否回车，回车则结束 
    JZ ENDOFTRANSFORM  
    CMP BX,6        ;看是否超长
    JZ ENDOFTRANSFORM   ;超长则结束
    ;否则继续转化
    CMP AL,'0'
    JGE MAYBENUM
    ;不是数字，看是否是退格
    CMP AL,'-'
    JZ BACKSPACE    ;退格
    ;不是退格 忽略该字符   
    JMP TLOOP
    
;可能是数字
MAYBENUM:
    CMP AL,'9'
    JLE ISLEGAL   ;是数字
    ;否则继续判断
    CMP AL,'A'
    JGE MAYBELETTER ;可能是字母
    ;否则有误，跳过
    JMP TLOOP

;合法输入    
ISLEGAL:
    MOV [SI],AL
    ADD SI,1
    INC BX
    JMP TLOOP

;可能是字母
MAYBELETTER:
    CMP AL,'Z'
    JLE ISLEGAL   ;大写字母
    ;否则看是否小写字母
    CMP AL,'a'
    JGE MAYBELOWER
    ;有误，跳过
    JMP TLOOP

;可能是小写字母
MAYBELOWER:
    CMP AL,'z'
    JLE ISLEGAL
    ;否则有误，跳过
    JMP TLOOP    
    
;退格     
BACKSPACE:
    SUB SI,1
    DEC BX
    JMP TLOOP

;字符串转化完成    
ENDOFTRANSFORM:
    MOV [SI],13  ;加一个结束符'\n'
    ADD SI,1
    JMP OUTPUTLOOP2


;**************进制转化*********************
;需要实现大整数加及大整数乘
SYSCONVERT PROC NEAR
STARTOFSYSCONVERT:
    LEA SI,STRINGBUFFER
    MOV AX,0
    PUSH AX
    
SYSLOOP:
    MOV AL,[SI]
    ADD SI,1
    CMP AL,13       ;'\n'即结束
    JZ ENDOFSYSCONVERT
    ;否则读数
    CMP AL,'9'
    JLE ISNUM       ;是数字
    ;否则判断是否大写字母
    CMP AL,'Z'
    JLE ISUPPER
    ;否则则是小写
    JMP ISLOWER
    
ISNUM:
    SUB AL,30H      ;ASCII->NUM
    CALL MULADD 
    JMP SYSLOOP

ISUPPER:
    JMP SYSLOOP
    
ISLOWER:
    JMP SYSLOOP
    
;乘上一位并加
;已用：DI,SI, DI是buffer,SI是STRINGBUFFER 
;AL中是要乘的数
MULADD:
    PUSH DI
    PUSH SI
    LEA DI,ARRAY
    LEA SI,RESULT
    MOV BL,STRINGLENGTH
    CMP BL,6
    JZ ISTX6
    CMP BL,5
    JZ ISTX5
    CMP BL,4
    JZ ISTX4
    CMP BL,3
    JZ ISTX3
    CMP BL,2
    JZ ISTX2
    CMP BL,1
    JZ ISTX1

;第六位
ISTX6: 
    LEA BX,TX6
    MOV CX,13
    JMP GMUL

;第五位
ISTX5: 
    LEA BX,TX5
    MOV CX,11
    JMP GMUL
    
;第四位
ISTX4: 
    LEA BX,TX4
    MOV CX,8
    JMP GMUL
    
;第三位
ISTX3: 
    LEA BX,TX3
    MOV CX,6
    JMP GMUL
    
;第二位
ISTX2: 
    LEA BX,TX2
    MOV CX,3
    JMP GMUL

;第一位  即乘1
ISTX1: 
    LEA BX,TX1
    MOV CX,1
    JMP GMUL
           
GMUL:
    MOV DL,STRINGLENGTH
    DEC DL
    MOV STRINGLENGTH,DL
    MOV DX,0            ;如果遇到0，说明循环结束
    PUSH DX
    
GMULLOOP:
    CMP AL,4        
    JGE GM1    ;过大，需要逐个乘
    ;只有一位数
    CALL ONEPLACE

GM1：
    MOV AH,0
    MOV DL,4
    DIV 4      ;除以4
    MOV DL,AH  ;余数放到DL
    MOV DH,0
    PUSH DX    ;数字压栈
    MOV AH,0
    JMP GMULLOOP
    
;RESULT+=ARRAY*AX
ONEPLACE: 
    MOV CH,0
    CALL OLOOP
    CALL CARRY
    RET

;CH当计数器    
OLOOP:
    XOR DX,DX
    MOV DL,CH
    MOV DL,PTR BX+DX    ;DL=TXN[DX]
    MUL DL              ;ARRAY[DX]*K->AX
    MOV PTR SI+BX,AL    ;AX->RESULT[DX]
    INC BX
    CMP BX,BITNUM
    JNZ OLOOP
    RET

;进位
CARRY:
    MOV BX,0
    CALL CLOOP
    MOV BX,BITNUM
    MOV AL,PTR SI+BX       ;RESULT[BITNUM]->AL
    CMP AL,0               ;IF RESULT[BITNUM]!=0
    JNZ NUMCARRAY
    RET

CLOOP:
    MOV DL,PTR SI+BX        ;RESULT[BX]->DL
    CMP DL,4               
    JGE CARRY1              ;IF (RESULT[BX]>4)->HANDLE IT
    INC BX                  ;++BX
    CMP BX,BITNUM
    JLE CLOOP
    RET

;进一位
CARRY1:
    MOV AL,PTR SI+BX        ;RESULT[BX]->AL
    DIV TEN                 ;RESULT[BX]/10->AX
    ADD PTR SI+BX+1,AL      ;RESULT[BX+1]+=RESULT[BX]/10
    MUL TEN                 
    SUB PTR SI+BX,AL        ;RESULT[BX]=RESULT[BX]%10
    INC BX
    CMP BX,BITNUM
    JLE CLOOP
    RET       
    
NUMCARRAY:
    MOV AX,BITNUM
    ADD AX,1
    MOV BITNUM,AX
    RET
                
;COPY RESULT TO ARRAY
MEMCPY:
    MOV BX,0
    CALL MCPYLOOP
    RET

MCPYLOOP:
    MOV AL,PTR SI+BX       ;RESULT[BX]->AL
    MOV PTR DI+BX,AL       ;AL->ARRAY[BX]
    INC BX
    ;CMP BX,20
    CMP BX,BITNUM
    JNZ MCPYLOOP
    RET    

ENDOFMULADD:
    POP SI
    POP DI
    RET
       
ENDOFSYSCONVERT:
    RET
SYSCONVERT ENDP
;*************进制转化结束*************

;结束
LEAVE:
    MOV AH,4CH
    INT 21H