;�����������   ���AX�е���
;�õ�AX,BX,CX,DX
;����CX���ڼ�¼λ��
;���������Χ�� -32767~32767
;���ȷ�����޷����������԰��������,��ô����
;���ж�Ϊ��������ȥ������DIV�ĳ�IDIV����JGE GETEN�ĳ�JA GETEN
;��Χ����0~65536
 
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
    JNS ISPOSITIVE      ;����
    ;�����Ǹ���
    PUSH AX                    
    MOV DL,45           ;���'-'
    MOV AH,02H                 
    INT 21H
    POP AX
    NEG AX              ;�ȱ������
    MOV CX,0            ;��������0 
    JMP ISPOSITIVE      ;����������
    
ISPOSITIVE:            
    CMP AX,10
    ;JGE  GETEN           ;>=10
    JA GETEN              ;�޷�����  >10
    JZ GETEN              ;=10
    JMP  LTTEN            ;<10
    
GETEN:
    ;MOV BL,10
    ;DIV BL               ;AX/10
    ;XOR BX,BX
    ;MOV BL,AH            ;�����ŵ�BL
    ;PUSH BX
    ;MOV AH,0             
    MOV DX,0
    MOV BX,10
    IDIV BX
    PUSH DX
    
    INC CX               ;λ����1
    JMP ISPOSITIVE       ;����ѭ�������Ƿ���Ҫ��� 

;����AXС��10�����
LTTEN:
    MOV BX,AX
    MOV DL,BL     
    ADD DL,30H
    MOV AH,02H
    INT 21H             
    ;�������ջ�д����
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

;�ָ�bx,cx,dx������            
ENDPRINTNUM:
    POP DX
    POP CX
    POP BX
    RET
    
PRINTNUM ENDP

LEAVE:

