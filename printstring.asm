;���һ����BUFFER�е��ַ���
;��Ҫ���壺
;BUFFER  DB 2048 DUP(0)
;BUFFSIZE DW ?
;�õ���AX,BX,CX
.DATA
    BUFFER  DB 2048 DUP(0)
    BUFFSIZE DW ?
    
.CODE
TESTPS:
    LEA DI,BUFFER
    MOV [DI],'A'
    ADD DI,1
    MOV [DI],'4'
    CALL PUTSTRING
    JMP LEAVE

PUTSTRING PROC NEAR
STARTPUTSTRING:
    PUSH AX
    PUSH DI
    LEA DI,BUFFER
    
PLOOP:
    MOV DL,[DI]
    CMP DL,0          ;��������'\0'
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

LEAVE: