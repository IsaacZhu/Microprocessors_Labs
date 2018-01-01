;输入并显示三角形

.DATA
BUFFER DB 255,0,255 DUP(0)    

.CODE
;带回显的输入
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
    MOV AL,PTR SI+2     ;读取第一个字符 是个数字
    SUB AL,30H          ;转化成数字
    MOV CH,AL           ;移到CH保存
    MOV DL,PTR SI+3     ;读取第二个字符 是将要输出的字符
    MOV DH,DL           ;暂存作为备份
    MOV CL,0
    MOV AH,02H                 
    ;输出 \n\r
    MOV DL,13               ;PRINT'\n'  (enter)
    INT 21H
    MOV DL,10               ;PRINT'\r'  (newline)
    INT 21H

;输出的外层循环，用CL计数    
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
    ;输出 \n\r
    MOV DL,13               ;PRINT'\n'  (enter)
    INT 21H
    MOV DL,10               ;PRINT'\r'  (newline)
    INT 21H
    JMP OUTERLOOP 
     
;内层循环，用BL计数    
INNERLOOP1:
    INC BL
    CMP BL,BH
    JA  ENDOFINNERLOOP 
    ;未结束 输出一个符号
    MOV DL,' '  ;输出空格
    INT 21H
    JMP INNERLOOP1

INNERLOOP2:
    INC BL
    CMP BL,BH
    JA  ENDOFINNERLOOP 
    ;未结束 输出一个符号
    MOV DL,DH
    MOV AH,02H
    INT 21H
    JMP INNERLOOP2
            
ENDOFINNERLOOP:
    RET    
    
    

;结束    
LEAVE:
    MOV AH,4CH
    INT 21H