;十六进制输出数字
;数字输出函数   输出AX中的数  输出大写A~F  如：A4H
;用到AX,BX,CX,DX
;其中CX用于记录位数
;输出的数范围是 -32767~32767
;如果确定是无符号数，可以按正数输出,那么可以
;把判断为正负部分去掉，把DIV改成IDIV，把JGE GETEN改成JA GETEN
;范围会变成0~65536
 
.MODEL SMALL
.STACK 1024

.CODE
START:
    MOV AX,256
    CALL PRINTNUMH
    JMP LEAVE
    
PRINTNUMH PROC NEAR 
    PUSH BX
    PUSH CX
    PUSH DX
    CMP AX,0
    JNZ NOTZERO
    ;IS ZERO  -> OUTPUT ZERO
    MOV DL,48
    MOV AH,02H
    INT 21H
    JMP ENDPRINTNUM
      
NOTZERO:
    MOV CX,0
    CMP AX,0
    JNS ISPOSITIVE      ;正数
    ;否则是负数
    PUSH AX                    
    MOV DL,45           ;输出'-'
    MOV AH,02H                 
    INT 21H
    POP AX
    NEG AX              ;先变成正数
    MOV CX,0            ;计数器清0 
    JMP ISPOSITIVE      ;按正数处理
    
ISPOSITIVE:            
    CMP AX,16
    JA GESIXTEEN          ;无符号数 >16
    JZ GESIXTEEN          ;=16
    JMP LTSIXTEEN         ;<16
    
GESIXTEEN:            
    MOV DX,0
    MOV BX,16
    IDIV BX
    PUSH DX
    
    INC CX               ;位数加1
    JMP ISPOSITIVE       ;继续循环，看是否需要输出 

;处理AX小于16的情况
LTSIXTEEN:
    CMP AX,10
    JB LTTEN             ;小于10
    ;否则是10到16
    ADD AX,55            ;输出AX中的数
    MOV DL,AL
    MOV AH,02H
    INT 21H
    JMP PLOOP            ;输出栈中存的数
    
;AX<10    
LTTEN:
    MOV BX,AX
    MOV DL,BL     
    ADD DL,30H
    MOV AH,02H
    INT 21H             
    ;以下输出栈中存的数
    JMP PLOOP   
    
PLOOP:
    DEC CX
    CMP CX,-1
    JZ ENDPRINTNUM
    POP AX
    CMP AX,10
    JGE LTSIXTEEN        ;10~15  
    JMP LTTEN            ;<10
    JMP PLOOP

;恢复bx,cx,dx并返回            
ENDPRINTNUM:
    MOV DL,72
    MOV AH,02H
    INT 21H
    POP DX
    POP CX
    POP BX
    RET
    
PRINTNUMH ENDP

LEAVE:
