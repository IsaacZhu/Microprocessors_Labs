;SORT THE NUMBERS IN FILE
;ZJR 11.24
.MODEL SMALL
.STACK 1024

.DATA
    FILENAME DB "F:/TEST.TXT",0
    FILEHANDLE DW
    N DB 0
    TEMP DB 0
    ARRAY DB 1024 DUP(0)

.CODE
;OPEN FILE:OPEN FILE NAMED "FILENAME"
FOPEN:
    MOV AX,716CH            ;CONTROL
    MOV BX,0                ;READ ONLY
    MOV CX,0                ;NORMAL MODE
    MOV DX,1                ;OPEN FILE
    MOV SI,OFFSET FILENAME  ;LOAD FILENAME
    INT 21H                 ;OPEN FILE

;READ FILE:COPY NUMBERS INTO ARRAY[]
RFILE:
    MOV FILEHANDLE,AX
    MOV AH,42H
    MOV BX,FILEHANDLE    

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
    MOV CX,0

;for (j=0;j<n-1;++j)    
OUTER_LOOP:
    MOV BX,0                ;BX IS THE COUNT VAR OF INNER LOOP 0~N-2-J
    CALL INNER_LOOP
    INC CX                  ;CX IS THE COUNT VAR OF OUTER LOOP 0~N-1
    MOV DI,OFFSET N
    CMP CX,[DI]             ;IF CX==N END
    JNE OUTER_LOOP
    JMP LEAVE
            
INNER_LOOP1:
    MOV DI,OFFSET ARRAY
    MOV AX,[DI+BX]          ;a[i]
    MOV DX,[DI+BX+1]        ;a[i+1]
    CMP AX,DX               ;if (a[i]>a[i+1])
    JG  EXC                 ;exchange a[i] and a[i+1]
    JMP INNER_LOOP2
    
INNER_LOOP2:                            
    INC BX                  ;++I
    MOV AX,N
    SUB AX,CX               ;N-J
    DEC AX                  ;N-J-1
    CMP BX,AX               ;I<N-1-J?
    JNE INNER_LOOP1         ;LOOP CONTINUE IF I<N-1-J
    RET 

;exchange AX and DX
EXC:
    MOV TEMP,AX
    MOV AX,DX
    MOV DX,TEMP
    JMP INNER_LOOP2
    
LEAVE:  MOV AH,4CH             ;END PROGRAM
        INT 21H
