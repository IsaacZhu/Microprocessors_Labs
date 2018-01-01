;��BUFFER�е��ֽ�ת�������ִ洢��ARRAY
;��ʽ�� A41 855 �Կո�Ϊ������
;ʮ������
;��Ҫ��ǰ���壺
;BUFFSIZE DW ?
;BUFFER DB 2048 DUP(0)
;N DW 0
;TEMP DW 0      
;ARRAY DB 1024 DUP(0)
;SIXTEEN DB 16

;�õ��ļĴ�����AX,BX,CX,SI,DI
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
    MOV AL,[SI]  ;�ȶ���һ����
    ADD SI,1
    CALL ASCNUMTONUM
    ;SUB AL,30H
    PUSH AX
    JMP RLOOP

;��AL�е�ASCIIת�������ִ浽AL
ASCTONUM:
    CMP AL,'A'   ;���Ƿ����10
    JB LETEN     ;С��10
    ;����10
    CMP AL,'a'   ;���Ǵ�д����Сд
    JB  UPPER    ;��д
    JMP LOWER    ;������Сд

;С��10    
LETEN:
    SUB AL,30H   ;��ȥ30����
    RET

;��д    
UPPER:
    SUB AL,65
    RET
 
;Сд    
LOWER:
    SUB AL,97
    RET

;��SI��ѭ��ȡ�ֽ�            
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

;����
ENDOFSTRINGTONUMH:
    POP SI
    POP DI
    POP CX
    POP BX
    POP AX
    RET
            
STRINGTONUMH ENDP