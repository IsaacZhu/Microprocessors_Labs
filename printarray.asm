.MODEL SMALL
.STACK 1024

.DATA
    MARRAY DB 37 DUP(0)

.CODE
START:  MOV CX,1

;STORE 1~36 TO MARRAY
STORE:  MOV DI,OFFSET MARRAY     ;load offset
        ADD DI,CX                ;MARRAY[CX]
        MOV [DI],CL              ;CX->MARRAY[CX]
        INC CX                   ;++CX
        CMP CX,37                ;IF CX==37 END
        JNE STORE
        MOV CX,0
        JMP OUTER_LOOP

;OUTER LOOP OF PRINT NUM        
OUTER_LOOP:
        MOV BX,1                ;BX IS THE COUNT VAR OF INNER LOOP 1~CX+1
        CALL INNER_LOOP
        MOV AH,02
        MOV DL,13               ;PRINT'\n'  (enter)
        INT 21H
        MOV DL,10               ;PRINT'\r'  (newline)
        INT 21H
        INC CX                  ;CX IS THE COUNT VAR OF OUTER LOOP 0~5
        CMP CX,6                ;IF CX==6 END
        JNE OUTER_LOOP
        JMP LEAVE

;INNER LOOP OF PRINT NUM        
INNER_LOOP:                     
        MOV AL,6                ;OFFSET=BX+CX*6
        MUL CL
        ADD AX,BX
        MOV DI,OFFSET MARRAY
        ADD DI,AX
        MOV DL,[DI]            ;MARRAY[BX+CX*6]->DL
        CMP DL,10              
        JGE GE10               ;IF DL>10 JUMP TO GE10
        JMP LT10               ;ELSE JUMP TO LT10

;PRINT A NUM THAT GREATER THAN OR EQUAL TO 10 (TWO PLACES)        
GE10:   XOR AX,AX
        MOV AL,DL              ;AL=DL
        MOV DL,10              ;DL=10
        DIV DL                 ;AL/10=AL...AH
        MOV DL,AL              ;DL=TEN PLACE
        MOV DH,AH              ;DH=ONE PLACE
        ADD DL,30H             ;ASCII
        MOV AH,02H
        INT 21H                ;PRINT TEN PLACE
        MOV DL,DH               
        ADD DL,30H             ;ASCII
        INT 21H                ;PRINT ONE PLACE
        MOV DL,32             
        INT 21H                ;PRINT " "
        MOV AX,CX              ;AX=CX+2
        ADD AX,2H
        INC BX
        CMP BX,AX
        JNE INNER_LOOP         ;BX<CX+2 CONTINUE
        RET                    ;BX==CX+2 INNER LOOP END 
        
;PRINT A NUM THAT LESS THAN 10(ONLY ONE PLACE)
LT10:   ADD DL,30H             ;ASCII
        XOR AX,AX              ;AX=0
        MOV AH,02H
        INT 21H                ;PRINT NUM
        MOV DL,32             
        INT 21H                ;PRINT " "
        INT 21H                ;PRINT ANOTHER " "
        MOV AX,CX              ;AX=CX+2
        ADD AX,2H
        INC BX
        CMP BX,AX
        JNE INNER_LOOP         ;BX<CX+2 CONTINUE
        RET                    ;BX==CX+2 INNER LOOP END
        
LEAVE:  MOV AH,4CH             ;END PROGRAM
        INT 21H 