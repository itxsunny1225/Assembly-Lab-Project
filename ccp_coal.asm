

.MODEL SMALL
.STACK 100H

.DATA
    MAX_RECORDS EQU 50
    RECORD_COUNT DW 0
    SR_NO DW MAX_RECORDS DUP(0)              
    NAMES DB MAX_RECORDS*20 DUP(' ')         
    FAMILY_MEMBERS DW MAX_RECORDS DUP(0)     
    WATER_CONSUME DW MAX_RECORDS DUP(0)     
    FLOUR_CONSUME DW MAX_RECORDS DUP(0)      
    PULSES_CONSUME DW MAX_RECORDS DUP(0)     
    
    MENU_MSG DB 13,10,'========================================',13,10
             DB '  REMOTE AREA MANAGEMENT SYSTEM',13,10
             DB '========================================',13,10
             DB '1. Add New Record',13,10
             DB '2. Update Record',13,10
             DB '3. Delete Record',13,10
             DB '4. Display All Records',13,10
             DB '5. Sort by Family Members',13,10
             DB '6. Sort by Water Consumption',13,10
             DB '7. Sort by Flour Consumption',13,10
             DB '8. Sort by Pulses Consumption',13,10
             DB '9. Show Total Statistics',13,10
             DB '0. Exit',13,10
             DB 'Enter Choice: $'
    
    PROMPT_SR DB 13,10,'Enter Sr#: $'
    PROMPT_NAME DB 'Enter Name (max 20 chars): $'
    PROMPT_FAMILY DB 'Enter Family Members: $'
    PROMPT_WATER DB 'Enter Water Consumption (liters): $'
    PROMPT_FLOUR DB 'Enter Flour Consumption (kg): $'
    PROMPT_PULSES DB 'Enter Pulses Consumption (kg): $'
    
    MSG_SUCCESS DB 13,10,'Operation Successful!',13,10,'$'
    MSG_DUPLICATE DB 13,10,'ERROR: Duplicate Sr# Found!',13,10,'$'
    MSG_NOT_FOUND DB 13,10,'ERROR: Record Not Found!',13,10,'$'
    MSG_FULL DB 13,10,'ERROR: Database Full!',13,10,'$'
    MSG_EMPTY DB 13,10,'Database is Empty!',13,10,'$'
    
    HEADER DB 13,10,'Sr#  Name                 Family  Water  Flour  Pulses',13,10
           DB '--------------------------------------------------------',13,10,'$'
    
    STAT_MSG DB 13,10,'========== TOTAL STATISTICS ==========',13,10,'$'
    TOTAL_FAM DB 'Total Family Members: $'
    TOTAL_WAT DB 13,10,'Total Water Consumption: $'
    TOTAL_FLR DB 13,10,'Total Flour Consumption: $'
    TOTAL_PLS DB 13,10,'Total Pulses Consumption: $'
    LITERS DB ' liters',13,10,'$'
    KG_MSG DB ' kg',13,10,'$'
    
    CHOICE DB ?
    TEMP_SR DW ?
    TEMP_NAME DB 21 DUP('$')
    TEMP_FAM DW ?
    TEMP_WAT DW ?
    TEMP_FLR DW ?
    TEMP_PLS DW ?
    TEMP_INDEX DW ?
    NEWLINE DB 13,10,'$'
    SPACE DB ' $'
    
.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
MAIN_LOOP:
    LEA DX, MENU_MSG
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H
    INT 21H
    SUB AL, 30H
    MOV CHOICE, AL
    
    PUSH AX
    PUSH DX
    MOV DL, 13
    MOV AH, 02H
    INT 21H
    MOV DL, 10
    MOV AH, 02H
    INT 21H
    POP DX
    POP AX
    
    CMP CHOICE, 0
    JE EXIT_PROGRAM
    CMP CHOICE, 1
    JE ADD_REC
    CMP CHOICE, 2
    JE UPDATE_REC
    CMP CHOICE, 3
    JE DELETE_REC
    CMP CHOICE, 4
    JE DISPLAY_REC
    CMP CHOICE, 5
    JE SORT_FAMILY
    CMP CHOICE, 6
    JE SORT_WATER
    CMP CHOICE, 7
    JE SORT_FLOUR
    CMP CHOICE, 8
    JE SORT_PULSES
    CMP CHOICE, 9
    JE SHOW_STATS
    JMP MAIN_LOOP

ADD_REC:
    CALL ADD_RECORD
    JMP MAIN_LOOP

UPDATE_REC:
    CALL UPDATE_RECORD
    JMP MAIN_LOOP

DELETE_REC:
    CALL DELETE_RECORD
    JMP MAIN_LOOP

DISPLAY_REC:
    CALL DISPLAY_ALL
    JMP MAIN_LOOP

SORT_FAMILY:
    MOV BX, 1
    CALL SORT_RECORDS
    CALL DISPLAY_ALL
    JMP MAIN_LOOP

SORT_WATER:
    MOV BX, 2
    CALL SORT_RECORDS
    CALL DISPLAY_ALL
    JMP MAIN_LOOP

SORT_FLOUR:
    MOV BX, 3
    CALL SORT_RECORDS
    CALL DISPLAY_ALL
    JMP MAIN_LOOP

SORT_PULSES:
    MOV BX, 4
    CALL SORT_RECORDS
    CALL DISPLAY_ALL
    JMP MAIN_LOOP

SHOW_STATS:
    CALL DISPLAY_STATISTICS
    JMP MAIN_LOOP

EXIT_PROGRAM:
    MOV AH, 4CH
    INT 21H
MAIN ENDP


ADD_RECORD PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    MOV AX, RECORD_COUNT
    CMP AX, MAX_RECORDS
    JGE DB_FULL
    
    LEA DX, PROMPT_SR
    MOV AH, 09H
    INT 21H
    CALL READ_NUMBER
    MOV TEMP_SR, AX
    
    CALL CHECK_DUPLICATE
    CMP AX, 1
    JE DUPLICATE_FOUND
    
    LEA DX, PROMPT_NAME
    MOV AH, 09H
    INT 21H
    LEA DX, TEMP_NAME
    CALL READ_STRING
    
    LEA DX, PROMPT_FAMILY
    MOV AH, 09H
    INT 21H
    CALL READ_NUMBER
    MOV TEMP_FAM, AX
    
    LEA DX, PROMPT_WATER
    MOV AH, 09H
    INT 21H
    CALL READ_NUMBER
    MOV TEMP_WAT, AX
    
    LEA DX, PROMPT_FLOUR
    MOV AH, 09H
    INT 21H
    CALL READ_NUMBER
    MOV TEMP_FLR, AX
    
    LEA DX, PROMPT_PULSES
    MOV AH, 09H
    INT 21H
    CALL READ_NUMBER
    MOV TEMP_PLS, AX
    
    MOV BX, RECORD_COUNT
    SHL BX, 1
    
    MOV AX, TEMP_SR
    MOV SR_NO[BX], AX
    
    MOV AX, TEMP_FAM
    MOV FAMILY_MEMBERS[BX], AX
    
    MOV AX, TEMP_WAT
    MOV WATER_CONSUME[BX], AX
    
    MOV AX, TEMP_FLR
    MOV FLOUR_CONSUME[BX], AX
    
    MOV AX, TEMP_PLS
    MOV PULSES_CONSUME[BX], AX
    
    MOV AX, RECORD_COUNT
    MOV CX, 20
    MUL CX
    MOV BX, AX
    LEA SI, TEMP_NAME
    LEA DI, NAMES
    ADD DI, BX
    MOV CX, 20
    REP MOVSB
    
    INC RECORD_COUNT
    
    LEA DX, MSG_SUCCESS
    MOV AH, 09H
    INT 21H
    JMP ADD_END

DB_FULL:
    LEA DX, MSG_FULL
    MOV AH, 09H
    INT 21H
    JMP ADD_END

DUPLICATE_FOUND:
    LEA DX, MSG_DUPLICATE
    MOV AH, 09H
    INT 21H

ADD_END:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
ADD_RECORD ENDP
UPDATE_RECORD PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    CMP RECORD_COUNT, 0
    JE UPD_EMPTY
    
    LEA DX, PROMPT_SR
    MOV AH, 09H
    INT 21H
    CALL READ_NUMBER
    MOV TEMP_SR, AX
    
    CALL FIND_RECORD
    CMP AX, 0FFFFH
    JE UPD_NOT_FOUND
    
    MOV TEMP_INDEX, AX
    SHL AX, 1
    MOV BX, AX
    LEA DX, PROMPT_NAME
    MOV AH, 09H
    INT 21H
    LEA DX, TEMP_NAME
    CALL READ_STRING
    
    LEA DX, PROMPT_FAMILY
    MOV AH, 09H
    INT 21H
    CALL READ_NUMBER
    MOV FAMILY_MEMBERS[BX], AX
    
    LEA DX, PROMPT_WATER
    MOV AH, 09H
    INT 21H
    CALL READ_NUMBER
    MOV WATER_CONSUME[BX], AX
    
    LEA DX, PROMPT_FLOUR
    MOV AH, 09H
    INT 21H
    CALL READ_NUMBER
    MOV FLOUR_CONSUME[BX], AX
    
    LEA DX, PROMPT_PULSES
    MOV AH, 09H
    INT 21H
    CALL READ_NUMBER
    MOV PULSES_CONSUME[BX], AX
    MOV AX, TEMP_INDEX
    MOV CX, 20
    MUL CX
    MOV BX, AX
    LEA SI, TEMP_NAME
    LEA DI, NAMES
    ADD DI, BX
    MOV CX, 20
    REP MOVSB
    
    LEA DX, MSG_SUCCESS
    MOV AH, 09H
    INT 21H
    JMP UPD_END

UPD_EMPTY:
    LEA DX, MSG_EMPTY
    MOV AH, 09H
    INT 21H
    JMP UPD_END

UPD_NOT_FOUND:
    LEA DX, MSG_NOT_FOUND
    MOV AH, 09H
    INT 21H

UPD_END:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
UPDATE_RECORD ENDP

DELETE_RECORD PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    CMP RECORD_COUNT, 0
    JE DEL_EMPTY
    
    LEA DX, PROMPT_SR
    MOV AH, 09H
    INT 21H
    CALL READ_NUMBER
    MOV TEMP_SR, AX
    
    CALL FIND_RECORD
    CMP AX, 0FFFFH
    JE DEL_NOT_FOUND
    
    MOV CX, AX
    INC CX
    
DEL_SHIFT_LOOP:
    CMP CX, RECORD_COUNT
    JGE DEL_SHIFT_DONE
    
    MOV SI, CX
    SHL SI, 1
    MOV DI, CX
    DEC DI
    SHL DI, 1
    
    MOV AX, SR_NO[SI]
    MOV SR_NO[DI], AX
    
    MOV AX, FAMILY_MEMBERS[SI]
    MOV FAMILY_MEMBERS[DI], AX
    
    MOV AX, WATER_CONSUME[SI]
    MOV WATER_CONSUME[DI], AX
    
    MOV AX, FLOUR_CONSUME[SI]
    MOV FLOUR_CONSUME[DI], AX
    
    MOV AX, PULSES_CONSUME[SI]
    MOV PULSES_CONSUME[DI], AX
    
    PUSH CX
    MOV AX, CX
    MOV CX, 20
    MUL CX
    MOV SI, AX
    
    POP CX
    PUSH CX
    MOV AX, CX
    DEC AX
    MOV CX, 20
    MUL CX
    MOV DI, AX
    
    LEA BX, NAMES
    ADD SI, BX
    ADD DI, BX
    MOV CX, 20
    REP MOVSB
    
    POP CX
    INC CX
    JMP DEL_SHIFT_LOOP

DEL_SHIFT_DONE:
    DEC RECORD_COUNT
    LEA DX, MSG_SUCCESS
    MOV AH, 09H
    INT 21H
    JMP DEL_END

DEL_EMPTY:
    LEA DX, MSG_EMPTY
    MOV AH, 09H
    INT 21H
    JMP DEL_END

DEL_NOT_FOUND:
    LEA DX, MSG_NOT_FOUND
    MOV AH, 09H
    INT 21H

DEL_END:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DELETE_RECORD ENDP

DISPLAY_ALL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    CMP RECORD_COUNT, 0
    JE DISP_EMPTY
    
    LEA DX, HEADER
    MOV AH, 09H
    INT 21H
    
    MOV CX, 0

DISP_LOOP:
    CMP CX, RECORD_COUNT
    JGE DISP_END
    
    MOV BX, CX
    SHL BX, 1
    
    MOV AX, SR_NO[BX]
    CALL PRINT_NUMBER
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    
    PUSH CX
    PUSH BX
    MOV AX, CX
    MOV BX, 20
    MUL BX
    MOV BX, AX
    LEA DX, NAMES
    ADD DX, BX
    MOV AH, 09H
    INT 21H
    POP BX
    POP CX
    
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    
    MOV BX, CX
    SHL BX, 1
    MOV AX, FAMILY_MEMBERS[BX]
    CALL PRINT_NUMBER
    
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    
    MOV AX, WATER_CONSUME[BX]
    CALL PRINT_NUMBER
    
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    
    MOV AX, FLOUR_CONSUME[BX]
    CALL PRINT_NUMBER
    
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    LEA DX, SPACE
    MOV AH, 09H
    INT 21H
    
    MOV AX, PULSES_CONSUME[BX]
    CALL PRINT_NUMBER
    
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    
    INC CX
    JMP DISP_LOOP

DISP_EMPTY:
    LEA DX, MSG_EMPTY
    MOV AH, 09H
    INT 21H

DISP_END:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DISPLAY_ALL ENDP
DISPLAY_STATISTICS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    CMP RECORD_COUNT, 0
    JE STAT_EMPTY
    
    LEA DX, STAT_MSG
    MOV AH, 09H
    INT 21H
    
    MOV AX, 0
    MOV TEMP_SR, AX
    MOV TEMP_FAM, AX
    MOV TEMP_WAT, AX
    MOV TEMP_FLR, AX
    
    MOV CX, 0

STAT_LOOP:
    CMP CX, RECORD_COUNT
    JGE STAT_DONE
    
    MOV BX, CX
    SHL BX, 1
    
    MOV AX, FAMILY_MEMBERS[BX]
    ADD TEMP_SR, AX
    
    MOV AX, WATER_CONSUME[BX]
    ADD TEMP_FAM, AX
    
    MOV AX, FLOUR_CONSUME[BX]
    ADD TEMP_WAT, AX
    
    MOV AX, PULSES_CONSUME[BX]
    ADD TEMP_FLR, AX
    
    INC CX
    JMP STAT_LOOP

STAT_DONE:
    LEA DX, TOTAL_FAM
    MOV AH, 09H
    INT 21H
    MOV AX, TEMP_SR
    CALL PRINT_NUMBER
    
    LEA DX, TOTAL_WAT
    MOV AH, 09H
    INT 21H
    MOV AX, TEMP_FAM
    CALL PRINT_NUMBER
    LEA DX, LITERS
    MOV AH, 09H
    INT 21H
    
    LEA DX, TOTAL_FLR
    MOV AH, 09H
    INT 21H
    MOV AX, TEMP_WAT
    CALL PRINT_NUMBER
    LEA DX, KG_MSG
    MOV AH, 09H
    INT 21H
    
    LEA DX, TOTAL_PLS
    MOV AH, 09H
    INT 21H
    MOV AX, TEMP_FLR
    CALL PRINT_NUMBER
    LEA DX, KG_MSG
    MOV AH, 09H
    INT 21H
    
    JMP STAT_EXIT

STAT_EMPTY:
    LEA DX, MSG_EMPTY
    MOV AH, 09H
    INT 21H

STAT_EXIT:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DISPLAY_STATISTICS ENDP
SORT_RECORDS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    MOV TEMP_INDEX, BX
    MOV CX, RECORD_COUNT
    DEC CX
    
SORT_OUTER:
    CMP CX, 0
    JLE SORT_DONE
    
    MOV SI, 0

SORT_INNER:
    CMP SI, CX
    JGE SORT_OUTER_NEXT
    
    MOV DI, SI
    INC DI
    
    MOV BX, SI
    SHL BX, 1
    MOV AX, FAMILY_MEMBERS[BX]
    
    CMP TEMP_INDEX, 2
    JNE SORT_CHK3
    MOV AX, WATER_CONSUME[BX]
    
SORT_CHK3:
    CMP TEMP_INDEX, 3
    JNE SORT_CHK4
    MOV AX, FLOUR_CONSUME[BX]
    
SORT_CHK4:
    CMP TEMP_INDEX, 4
    JNE SORT_GET_SECOND
    MOV AX, PULSES_CONSUME[BX]
    
SORT_GET_SECOND:
    PUSH AX
    MOV BX, DI
    SHL BX, 1
    MOV DX, FAMILY_MEMBERS[BX]
    
    CMP TEMP_INDEX, 2
    JNE SORT_CMP3
    MOV DX, WATER_CONSUME[BX]
    
SORT_CMP3:
    CMP TEMP_INDEX, 3
    JNE SORT_CMP4
    MOV DX, FLOUR_CONSUME[BX]
    
SORT_CMP4:
    CMP TEMP_INDEX, 4
    JNE SORT_DO_CMP
    MOV DX, PULSES_CONSUME[BX]
    
SORT_DO_CMP:
    POP AX
    CMP AX, DX
    JLE SORT_NO_SWAP
    
    CALL SWAP_RECORDS
    
SORT_NO_SWAP:
    INC SI
    JMP SORT_INNER

SORT_OUTER_NEXT:
    DEC CX
    JMP SORT_OUTER

SORT_DONE:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SORT_RECORDS ENDP
SWAP_RECORDS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    PUSH SI
    PUSH DI
    
    SHL SI, 1
    SHL DI, 1
    
    MOV AX, SR_NO[SI]
    MOV DX, SR_NO[DI]
    MOV SR_NO[SI], DX
    MOV SR_NO[DI], AX
    
    MOV AX, FAMILY_MEMBERS[SI]
    MOV DX, FAMILY_MEMBERS[DI]
    MOV FAMILY_MEMBERS[SI], DX
    MOV FAMILY_MEMBERS[DI], AX
    
    MOV AX, WATER_CONSUME[SI]
    MOV DX, WATER_CONSUME[DI]
    MOV WATER_CONSUME[SI], DX
    MOV WATER_CONSUME[DI], AX
    
    MOV AX, FLOUR_CONSUME[SI]
    MOV DX, FLOUR_CONSUME[DI]
    MOV FLOUR_CONSUME[SI], DX
    MOV FLOUR_CONSUME[DI], AX
    
    MOV AX, PULSES_CONSUME[SI]
    MOV DX, PULSES_CONSUME[DI]
    MOV PULSES_CONSUME[SI], DX
    MOV PULSES_CONSUME[DI], AX
    
    POP DI
    POP SI
    
    PUSH SI
    PUSH DI
    
    MOV AX, SI
    MOV CX, 20
    MUL CX
    MOV SI, AX
    
    MOV AX, DI
    MOV CX, 20
    MUL CX
    MOV DI, AX
    
    LEA BX, NAMES
    ADD SI, BX
    ADD DI, BX
    
    MOV CX, 20
SWAP_NAME_LOOP:
    MOV AL, [SI]
    MOV AH, [DI]
    MOV [SI], AH
    MOV [DI], AL
    INC SI
    INC DI
    LOOP SWAP_NAME_LOOP
    
    POP DI
    POP SI
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SWAP_RECORDS ENDP
CHECK_DUPLICATE PROC
    PUSH BX
    PUSH CX
    
    MOV CX, 0
    
CHK_LOOP:
    CMP CX, RECORD_COUNT
    JGE CHK_NOT_FOUND
    
    MOV BX, CX
    SHL BX, 1
    MOV AX, SR_NO[BX]
    CMP AX, TEMP_SR
    JE CHK_FOUND
    
    INC CX
    JMP CHK_LOOP

CHK_FOUND:
    MOV AX, 1
    JMP CHK_END

CHK_NOT_FOUND:
    MOV AX, 0

CHK_END:
    POP CX
    POP BX
    RET
CHECK_DUPLICATE ENDP
FIND_RECORD PROC
    PUSH BX
    PUSH CX
    
    MOV CX, 0

FIND_LOOP:
    CMP CX, RECORD_COUNT
    JGE FIND_NOT_FOUND
    
    MOV BX, CX
    SHL BX, 1
    MOV AX, SR_NO[BX]
    CMP AX, TEMP_SR
    JE FIND_FOUND
    
    INC CX
    JMP FIND_LOOP

FIND_FOUND:
    MOV AX, CX
    JMP FIND_END

FIND_NOT_FOUND:
    MOV AX, 0FFFFH

FIND_END:
    POP CX
    POP BX
    RET
FIND_RECORD ENDP

READ_STRING PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI
    
    MOV DI, DX
    MOV CX, 0
    
    PUSH DI
    MOV AL, ' '
    MOV CX, 20
CLEAR_BUFFER:
    MOV [DI], AL
    INC DI
    LOOP CLEAR_BUFFER
    POP DI
    
    MOV CX, 0
    
READ_STR_LOOP:
    MOV AH, 01H
    INT 21H
    
    CMP AL, 13
    JE READ_STR_DONE
    
    CMP AL, 8
    JE HANDLE_STR_BACKSPACE
    
    CMP CX, 20
    JGE READ_STR_LOOP
    
    MOV [DI], AL
    INC DI
    INC CX
    JMP READ_STR_LOOP

HANDLE_STR_BACKSPACE:
    CMP CX, 0
    JE READ_STR_LOOP
    
    DEC DI
    MOV BYTE PTR [DI], ' '
    DEC CX
    JMP READ_STR_LOOP

READ_STR_DONE:
    MOV DI, DX
    ADD DI, 20
    MOV BYTE PTR [DI], '$'
    
    PUSH DX
    MOV DL, 13
    MOV AH, 02H
    INT 21H
    MOV DL, 10
    MOV AH, 02H
    INT 21H
    POP DX
    
    POP DI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
READ_STRING ENDP
READ_NUMBER PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    SUB SP, 10
    MOV SI, SP
    
    MOV AX, 0
    MOV BX, 10
    MOV CX, 0
    
READ_DIGIT:
    MOV AH, 01H
    INT 21H
    
    CMP AL, 13
    JE READ_NUM_DONE
    
    CMP AL, 8
    JE HANDLE_BACKSPACE
    
    CMP AL, '0'
    JB READ_DIGIT
    CMP AL, '9'
    JA READ_DIGIT
    
    MOV [SI], AL
    INC SI
    INC CX
    
    CMP CX, 5
    JL READ_DIGIT
    JMP READ_DIGIT

HANDLE_BACKSPACE:
    CMP CX, 0
    JE READ_DIGIT
    DEC SI
    DEC CX
    JMP READ_DIGIT

READ_NUM_DONE:
    SUB SI, CX
    MOV AX, 0
    MOV BX, 10
    
CONVERT_LOOP:
    CMP CX, 0
    JE CONVERSION_DONE
    
    MOV DL, [SI]
    SUB DL, '0'
    MOV DH, 0
    PUSH DX
    MUL BX
    POP DX
    ADD AX, DX
    
    INC SI
    DEC CX
    JMP CONVERT_LOOP

CONVERSION_DONE:
    ADD SP, 10
    
    PUSH AX
    MOV DL, 13
    MOV AH, 02H
    INT 21H
    MOV DL, 10
    MOV AH, 02H
    INT 21H
    POP AX
    
    POP SI
    POP DX
    POP CX
    POP BX
    RET
READ_NUMBER ENDP
PRINT_NUMBER PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    CMP AX, 0
    JNE PRINT_NOT_ZERO
    
    PUSH DX
    MOV DL, '0'
    MOV AH, 02H
    INT 21H
    POP DX
    JMP PRINT_NUM_EXIT

PRINT_NOT_ZERO:
    MOV BX, 10
    MOV CX, 0

DIVIDE_LOOP:
    MOV DX, 0
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE DIVIDE_LOOP

PRINT_LOOP:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PRINT_LOOP

PRINT_NUM_EXIT:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUMBER ENDP

END MAIN
