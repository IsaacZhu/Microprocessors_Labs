;SORT THE NUMBERS IN FILE
;ZJR 11.24
INCLUDE EMU8086.INC
.MODEL SMALL
.STACK 1024

.DATA
    FILENAME DB 'D:\SOFTWARE\emu8086\emu8086\MyBuild\TEST.TXT',0
    FILEHANDLE DW ?
    FILEHI DW ?
    FILELO DW ?
    BUFFSIZE DW ?
    BUFFER DB 2048 DUP(0)
    N DW 0
    TEMP DW 0      
    ARRAY DB 1024 DUP(0)
    TEN DB 10
    
.CODE    
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

;READ NUM FROM BUFFER TO ARRAY[]    
READNUM:
    XOR AX,AX
    MOV CX,1    ;COUNT BUFFER
    MOV BX,0    ;COUNT ARRAY
    MOV SI,OFFSET BUFFER
    MOV DI,OFFSET ARRAY
    MOV AL,[SI]
    ADD SI,1
    SUB AL,30H
    PUSH AX
    
RLOOP:
    MOV AL,[SI]
    CMP AL,32  ;BUFFER(CX)==' '?
    JE RSPACE
    ;IS NUMBER
    POP AX         ;LAST PLACE *10
    MUL TEN
    ADD AL,[SI]
    SUB AL,30H      ;ASCII -> NUM
    PUSH AX
    ADD SI,1
    INC CX
    CMP CX,BUFFSIZE
    JZ BSORT        ;READ END
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
    SUB AL,30H
    PUSH AX
    ADD SI,1

    ADD CX,2
    CMP CX,BUFFSIZE
    JZ BSORT
    JMP RLOOP
    
;BUBBLE SORT
BSORT:
    ;void bubble_sort(int a[],int n){
    ;int i,j,tmp;
    ;for (j=0;j<n-1;++j){
    ;   for (i=0;i<n-1-j;++i){
    ;       if (a[i]>a[i+1]){
    ;           temp=a[i];
    ;           a[i]=a[i+1];
    ;           a[i+1]=temp;
    ;       }
    ;   }
    ;}
    POP AX
    MOV [DI],AL     ;ARRAY[BX]
    INC BX
    
    MOV N,BX             ;STORE N
    MOV CX,0

;for (j=0;j<n-1;++j)           

OUTER_LOOP:
    MOV BX,0                ;BX IS THE COUNT VAR OF INNER LOOP 0~N-2-J
    CALL INNER_LOOP1
    INC CX                  ;CX IS THE COUNT VAR OF OUTER LOOP 0~N-1
    CMP CX,N                ;IF CX==N END
    JNE OUTER_LOOP
    JMP PRINTR
            
INNER_LOOP1:
    XOR AX,AX
    XOR DX,DX
    MOV DI,OFFSET ARRAY
    MOV AL,PTR DI+BX             ;a[i]
    ;CALL PRINT_NUM
    MOV DL,PTR DI+BX+1      ;a[i+1]
    CMP AL,DL               ;if (a[i]>a[i+1])
    JA  EXC                 ;exchange a[i] and a[i+1]
    JMP INNER_LOOP2
    
INNER_LOOP2:
    ADD DI,1                            
    INC BX                  ;++I
    MOV AX,N
    SUB AX,CX               ;N-J
    DEC AX                  ;N-J-1
    CMP BX,AX               ;I<N-1-J?
    JB  INNER_LOOP1         ;LOOP CONTINUE IF I<N-1-J
    RET 

;exchange AX and DX
EXC:
    MOV TEMP,AX
    MOV AX,DX
    MOV DX,TEMP
    MOV PTR DI+BX,AL
    MOV PTR DI+BX+1,DL
    JMP INNER_LOOP2

;PRINT RESULT
PRINTR:
    MOV CX,0
    MOV DI,OFFSET ARRAY
    
PLOOP:
    ;MOV AH,02H
    ;MOV DL,[DI]
    ;ADD DL,30H
    ;INT 21H
    MOV AL,[DI]
    CALL PRINT_NUM
    PUTC 32             ;PRINT " "
    ADD DI,1
    INC CX
    CMP CX,N
    JNE PLOOP
            
LEAVE:  MOV AH,4CH             ;END PROGRAM
        INT 21H
        DEFINE_PRINT_NUM_UNS
        DEFINE_PRINT_NUM