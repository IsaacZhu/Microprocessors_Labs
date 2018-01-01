;���벢��ʾ������

.DATA
BUFFER DB 255,0,255 DUP(0)    

.CODE
;�����Ե�����
INPUT:
    MOV AX,@data
    MOV DS,AX
    XOR AX,AX 
    MOV DX,OFFSET BUFFER
    MOV AH,10
    INT 21H 
    
START:
    LEA DI,BUFFER
    XOR AX,AX
    MOV AL,PTR SI+2     ;��ȡ��һ���ַ� �Ǹ�����
    SUB AL,30H          ;ת��������
    MOV CH,AL           ;�Ƶ�CH����
    MOV DL,PTR SI+3     ;��ȡ�ڶ����ַ� �ǽ�Ҫ������ַ�
    MOV DH,DL           ;�ݴ���Ϊ����
    MOV CL,0
    MOV AH,02H                 
    ;��� \n\r
    MOV DL,13               ;PRINT'\n'  (enter)
    INT 21H
    MOV DL,10               ;PRINT'\r'  (newline)
    INT 21H

;��������ѭ������CL����    
OUTERLOOP: 
    INC CL
    CMP CL,CH           
    JA LEAVE  
    MOV BH,CH
    SUB BH,CL               ;CH-CL -> BH
    MOV BL,0
    CALL INNERLOOP1
    MOV BH,CL
    ADD BH,BH               ;2*CL
    DEC BH                  ;2*CL-1 -> BH
    MOV BL,0
    CALL INNERLOOP2
    ;��� \n\r
    MOV DL,13               ;PRINT'\n'  (enter)
    INT 21H
    MOV DL,10               ;PRINT'\r'  (newline)
    INT 21H
    JMP OUTERLOOP 
     
;�ڲ�ѭ������BL����    
INNERLOOP1:
    INC BL
    CMP BL,BH
    JA  ENDOFINNERLOOP 
    ;δ���� ���һ������
    MOV DL,' '  ;����ո�
    INT 21H
    JMP INNERLOOP1

INNERLOOP2:
    INC BL
    CMP BL,BH
    JA  ENDOFINNERLOOP 
    ;δ���� ���һ������
    MOV DL,DH
    MOV AH,02H
    INT 21H
    JMP INNERLOOP2
            
ENDOFINNERLOOP:
    RET    
    
    

;����    
LEAVE:
    MOV AH,4CH
    INT 21H