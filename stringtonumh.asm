;把BUFFER中的字节转换成数字存储到ARRAY
;格式是 A41 855 以空格为结束？
;十六进制
;需要提前定义：
;BUFFSIZE DW ?
;BUFFER DB 2048 DUP(0)
;N DW 0
;TEMP DW 0      
;ARRAY DB 1024 DUP(0)
;SIXTEEN DB 16

;用到的寄存器：AX,BX,CX,SI,DI
.DATA
    BUFFSIZE DW ?
    BUFFER DB 2048 DUP(0)
    N DW 0
    TEMP DW 0      
    ARRAY DB 1024 DUP(0)
    SIXTEEN DB 16

.CODE
STRINGTONUMH PROC NEAR
STRATSTNH:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DI
    PUSH SI
    
;READ NUM FROM BUFFER TO ARRAY[]    
READNUM:
    XOR AX,AX
    MOV CX,1    ;COUNT BUFFER
    MOV BX,0    ;COUNT ARRAY
    MOV SI,OFFSET BUFFER
    MOV DI,OFFSET ARRAY
    MOV AL,[SI]  ;先读第一个数
    ADD SI,1
    CALL ASCNUMTONUM
    ;SUB AL,30H
    PUSH AX
    JMP RLOOP

;把AL中的ASCII转化成数字存到AL
ASCTONUM:
    CMP AL,'A'   ;看是否大于10
    JB LETEN     ;小于10
    ;大于10
    CMP AL,'a'   ;看是大写还是小写
    JB  UPPER    ;大写
    JMP LOWER    ;否则是小写

;小于10    
LETEN:
    SUB AL,30H   ;减去30即可
    RET

;大写    
UPPER:
    SUB AL,65
    RET
 
;小写    
LOWER:
    SUB AL,97
    RET

;从SI中循环取字节            
RLOOP:
    MOV AL,[SI]
    CMP AL,32        ;BUFFER(CX)==' '?
    JE RSPACE
    ;IS NUMBER
    POP AX           ;LAST PLACE *16
    MUL SIXTEEN     
    ADD AL,[SI]
    CALL ASCTONUM    ;ASCII -> NUM 
    PUSH AX
    ADD SI,1
    INC CX
    CMP CX,BUFFSIZE
    JZ ENDOFSTRINGTONUMH        ;READ END
    JMP RLOOP  

;MEET A SPACE-> STORE A NUMBER TO ARRAY
RSPACE:
    POP AX
    MOV [DI],AL     ;ARRAY[BX]
    INC BX
    ADD DI,1
    
    XOR AX,AX       ;NEXT NUM
    ADD SI,1
    MOV AL,[SI]
    ;SUB AL,30H
    CALL ASCTONUM    ;ASCII -> NUM
    PUSH AX
    ADD SI,1

    ADD CX,2
    CMP CX,BUFFSIZE
    JZ ENDOFSTRINGTONUMH
    JMP RLOOP

;结束
ENDOFSTRINGTONUMH:
    POP SI
    POP DI
    POP CX
    POP BX
    POP AX
    RET
            
STRINGTONUMH ENDP