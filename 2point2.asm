;2.1 ��ʾSample.txt
.MODEL SMALL
.STACK 1024

.DATA
    FILENAME DB 'D:\SOFTWARE\emu8086\emu8086\MyBuild\Sample.txt',0
    FILEHANDLE DW ?
    FILEHI DW ?
    FILELO DW ?
    BUFFSIZE DW ?
    BUFFER DB 2048 DUP(0)
    STRINGBUFFER DB 1024 DUP(0) ;�洢ת������ַ���
    RESULT DB 1024 DUP(0)       ;�ݴ������
    ARRAY DB 1024 DUP(0)        ;�洢�ַ���ת�����ɵ��Ľ�����
    STRINGLENGTH DW 0     
    TX6 DB 3,2,1,2,2,2,2,1,0,0,0,0,0      ;���36^5   13λ
    TX5 DB 1,2,1,2,2,0,1,0,0,0,0          ;���36^4   11λ
    TX4 DB 2,3,1,2,1,0,0,0                ;36^3         8λ
    TX3 DB 1,1,0,1,0,0                    ;36^2 = 1296  6λ
    TX2 DB 2,1,0                          ;36           3λ
    TX1 DB 1                              ;1            1λ
    BITNUM DW 1
    
.CODE
START:
    CALL PREADFILE          ;���ļ����ݶ���buffer
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

;��ʾ�ļ�һ��
PUTSTRING PROC NEAR
STARTPUTSTRING:
    PUSH AX
    PUSH DI
    LEA DI,STRINGBUFFER
    
PLOOP:
    MOV DL,[DI]
    CMP DL,13          ;��������'\n'
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

;ת��ÿһ�в����
OUTPUTLOOP1:
    LEA DI,BUFFER
    MOV BX,0
    JMP TRANSFORM
    
OUTPUTLOOP2:
    MOV STRINGLENGTH,BX ;�ó��Ȳ�����'\n'
    CALL PUTSTRING      ;���ת������ַ���
    CALL SYSCONVERT     ;����ת��
    JMP OUTPUTLOOP1     ;����ѭ��������һ��
    JMP LEAVE
    
    
;���ַ�������ʽת��
TRANSFORM:     
    LEA SI,STRINGBUFFER
    
TLOOP:
    MOV AL,[DI]
    ADD DI,1
    CMP AL,13       ;���Ƿ�س����س������ 
    JZ ENDOFTRANSFORM  
    CMP BX,6        ;���Ƿ񳬳�
    JZ ENDOFTRANSFORM   ;���������
    ;�������ת��
    CMP AL,'0'
    JGE MAYBENUM
    ;�������֣����Ƿ����˸�
    CMP AL,'-'
    JZ BACKSPACE    ;�˸�
    ;�����˸� ���Ը��ַ�   
    JMP TLOOP
    
;����������
MAYBENUM:
    CMP AL,'9'
    JLE ISLEGAL   ;������
    ;��������ж�
    CMP AL,'A'
    JGE MAYBELETTER ;��������ĸ
    ;������������
    JMP TLOOP

;�Ϸ�����    
ISLEGAL:
    MOV [SI],AL
    ADD SI,1
    INC BX
    JMP TLOOP

;��������ĸ
MAYBELETTER:
    CMP AL,'Z'
    JLE ISLEGAL   ;��д��ĸ
    ;�����Ƿ�Сд��ĸ
    CMP AL,'a'
    JGE MAYBELOWER
    ;��������
    JMP TLOOP

;������Сд��ĸ
MAYBELOWER:
    CMP AL,'z'
    JLE ISLEGAL
    ;������������
    JMP TLOOP    
    
;�˸�     
BACKSPACE:
    SUB SI,1
    DEC BX
    JMP TLOOP

;�ַ���ת�����    
ENDOFTRANSFORM:
    MOV [SI],13  ;��һ��������'\n'
    ADD SI,1
    JMP OUTPUTLOOP2


;**************����ת��*********************
;��Ҫʵ�ִ������Ӽ���������
SYSCONVERT PROC NEAR
STARTOFSYSCONVERT:
    LEA SI,STRINGBUFFER
    MOV AX,0
    PUSH AX
    
SYSLOOP:
    MOV AL,[SI]
    ADD SI,1
    CMP AL,13       ;'\n'������
    JZ ENDOFSYSCONVERT
    ;�������
    CMP AL,'9'
    JLE ISNUM       ;������
    ;�����ж��Ƿ��д��ĸ
    CMP AL,'Z'
    JLE ISUPPER
    ;��������Сд
    JMP ISLOWER
    
ISNUM:
    SUB AL,30H      ;ASCII->NUM
    CALL MULADD 
    JMP SYSLOOP

ISUPPER:
    JMP SYSLOOP
    
ISLOWER:
    JMP SYSLOOP
    
;����һλ����
;���ã�DI,SI, DI��buffer,SI��STRINGBUFFER 
;AL����Ҫ�˵���
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

;����λ
ISTX6: 
    LEA BX,TX6
    MOV CX,13
    JMP GMUL

;����λ
ISTX5: 
    LEA BX,TX5
    MOV CX,11
    JMP GMUL
    
;����λ
ISTX4: 
    LEA BX,TX4
    MOV CX,8
    JMP GMUL
    
;����λ
ISTX3: 
    LEA BX,TX3
    MOV CX,6
    JMP GMUL
    
;�ڶ�λ
ISTX2: 
    LEA BX,TX2
    MOV CX,3
    JMP GMUL

;��һλ  ����1
ISTX1: 
    LEA BX,TX1
    MOV CX,1
    JMP GMUL
           
GMUL:
    MOV DL,STRINGLENGTH
    DEC DL
    MOV STRINGLENGTH,DL
    MOV DX,0            ;�������0��˵��ѭ������
    PUSH DX
    
GMULLOOP:
    CMP AL,4        
    JGE GM1    ;������Ҫ�����
    ;ֻ��һλ��
    CALL ONEPLACE

GM1��
    MOV AH,0
    MOV DL,4
    DIV 4      ;����4
    MOV DL,AH  ;�����ŵ�DL
    MOV DH,0
    PUSH DX    ;����ѹջ
    MOV AH,0
    JMP GMULLOOP
    
;RESULT+=ARRAY*AX
ONEPLACE: 
    MOV CH,0
    CALL OLOOP
    CALL CARRY
    RET

;CH��������    
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

;��λ
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

;��һλ
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
;*************����ת������*************

;����
LEAVE:
    MOV AH,4CH
    INT 21H