;ʮ�������������
;�����������   ���AX�е���  �����дA~F  �磺A4H
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
    CMP AX,16
    JA GESIXTEEN          ;�޷����� >16
    JZ GESIXTEEN          ;=16
    JMP LTSIXTEEN         ;<16
    
GESIXTEEN:            
    MOV DX,0
    MOV BX,16
    IDIV BX
    PUSH DX
    
    INC CX               ;λ����1
    JMP ISPOSITIVE       ;����ѭ�������Ƿ���Ҫ��� 

;����AXС��16�����
LTSIXTEEN:
    CMP AX,10
    JB LTTEN             ;С��10
    ;������10��16
    ADD AX,55            ;���AX�е���
    MOV DL,AL
    MOV AH,02H
    INT 21H
    JMP PLOOP            ;���ջ�д����
    
;AX<10    
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
    CMP AX,10
    JGE LTSIXTEEN        ;10~15  
    JMP LTTEN            ;<10
    JMP PLOOP

;�ָ�bx,cx,dx������            
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
