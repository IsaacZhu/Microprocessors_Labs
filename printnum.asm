;数字输出函数   输出AX中的数
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
    MOV AX,-32767
    CALL PRINTNUM
    JMP LEAVE
    
PRINTNUM PROC NEAR 
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
    CMP AX,10
    ;JGE  GETEN           ;>=10
    JA GETEN              ;无符号数  >10
    JZ GETEN              ;=10
    JMP  LTTEN            ;<10
    
GETEN:
    ;MOV BL,10
    ;DIV BL               ;AX/10
    ;XOR BX,BX
    ;MOV BL,AH            ;余数放到BL
    ;PUSH BX
    ;MOV AH,0             
    MOV DX,0
    MOV BX,10
    IDIV BX
    PUSH DX
    
    INC CX               ;位数加1
    JMP ISPOSITIVE       ;继续循环，看是否需要输出 

;处理AX小于10的情况
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
    MOV DL,AL
    ADD DL,30H
    MOV AH,02H
    INT 21H
    JMP PLOOP

;恢复bx,cx,dx并返回            
ENDPRINTNUM:
    POP DX
    POP CX
    POP BX
    RET
    
PRINTNUM ENDP

LEAVE:

