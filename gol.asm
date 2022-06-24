; CONWAY'S GAME OF LIFE IN CCSID 437. ASSEMBLED BY MASM.

;MACROS
DRAW MACRO CHARD, PX, PY, COL
    MOV DH, PY
    MOV DL, PX
    CALL GOTOXY

    MOV AH, 09
    MOV AL, CHARD
    MOV BL, COL
    MOV CX, 1
    INT 10H
ENDM DRAWPLAYER

DELAYSMS MACRO VCX, VDX ; VCX:VDX IN MS
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, SEC
    MOV DX, MILISEC
    MOV AH, 86H
    INT 15H

    POP DX
    POP CX
    POP BX
    POP AX
ENDM DELAY

.MODEL LARGE
.386
.STACK 100H
.DATA
    ; cursor position
    POSX DB 40
    POSY DB 10

    ; MAT ITER POS CTR
    MPX DB ?
    MPY DB ?
    
    DSHAPE DB 219
    LSHAPE DB ?
    DCOLOR DB 0EH
    LCOLOR DB ?

    SEEDM DB 2000 DUP(0) ; 80X25 -- FLATTENED 2D ARR, ACCESSINDEX=POSY*80+POSX... boolean use
    
.CODE
    MAIN PROC
        MOV AX, @DATA
        MOV DS, AX

        CALL CLEARSCREEN

        DRAW DSHAPE, POSX, POSY, DCOLOR

        MAINLOOP:
            PUSH AX
            PUSH BX

            MOV AL, POSY
            MOV BL, 80
            MUL BL
            MOV BL, POSX
            XOR BH, BH
            ADD AX, BX
            MOV BX, AX

            CMP SEEDM[BX], 1
            JE SEEDED

            MOV LSHAPE, ' '
            MOV LCOLOR, 0EH
            JMP CHECKOUT

            SEEDED:
                MOV LSHAPE, 219
                MOV LCOLOR, 0CH

            CHECKOUT:
                POP BX
                POP AX

            ; COMMAND INPUT
            CALL READCHAR
            CMP AH, 048H
            JE MOVEUP
            CMP AH, 04BH
            JE MOVELEFT
            CMP AH, 050H
            JE MOVEDOWN
            CMP AH, 04DH
            JE MOVERIGHT
            CMP AH, 039H
            JE PLACESEED
            CMP AH, 01CH
            JE STARTLIFE
            CMP AH, 01H
            JE EXITP
            JMP CYCLE

            MOVEUP:
                DRAW LSHAPE, POSX, POSY, LCOLOR
                DEC POSY
                CMP POSY, 25
                JB SET
                INC POSY
                JMP SET
            MOVEDOWN:
                DRAW LSHAPE, POSX, POSY, LCOLOR
                INC POSY
                CMP POSY, 25
                JB SET
                DEC POSY
                JMP SET
            MOVELEFT:
                DRAW LSHAPE, POSX, POSY, LCOLOR
                DEC POSX
                CMP POSX, 78
                JB SET
                INC POSX
                JMP SET
            MOVERIGHT:
                DRAW LSHAPE, POSX, POSY, LCOLOR
                INC POSX
                CMP POSX, 78
                JB SET
                DEC POSX
                JMP SET
            PLACESEED:
                PUSH AX
                PUSH BX

                MOV AL, POSY
                MOV BL, 80
                MUL BL
                MOV BL, POSX
                XOR BH, BH
                ADD AX, BX
                MOV BX, AX

                CMP SEEDM[BX], 1
                JE DELETE

                MOV SEEDM[BX], 1
                DRAW DSHAPE, POSX, POSY, 0CH
                JMP PSEEDOUT

                DELETE:
                    MOV SEEDM[BX], 0
                    DRAW ' ', POSX, POSY, 0CH

                PSEEDOUT:
                    POP BX
                    POP AX

                JMP CYCLE

            SET:
                DRAW 219, POSX, POSY, 0EH

            CYCLE:
            JMP MAINLOOP

            STARTLIFE:
                CALL READCHAR
                CMP AH, 01H
                JE EXITP
                CMP AH, 01CH
                JE MAINLOOP

                ; MAIN BS HERE
                MOV CX, 0 ; ITERATOR


                CALL DELAY
                JMP STARTLIFE

        EXITP:
            MOV AH, 4CH
            INT 21H
    MAIN ENDP

    ;essentiap proc
    WRITEINT PROC ; (DECIMAL) AX = VALUE
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
    
        MOV BX, 10
        XOR CX, CX
        MOV CX, 1
    
        PARSE:
            INC CX
            XOR DX, DX      
            DIV BX
            ADD DX, 48
            PUSH DX
            CMP AX, 10
            JG PARSE
        
            CMP AX, 0
            JE PREPRINT
            
        FIRSTDIGIT:
            ADD AX, 48
            PUSH AX
            
        PREPRINT:
            DEC CX
            
        PRINT:
            POP DX
            MOV AH, 2
            INT 21H
            DEC CX
            CMP CX, 0
            JNE PRINT   
            
        POP DX
        POP CX
        POP BX
        POP AX
        RET
    WRITEINT ENDP

    GOTOXY PROC ;DH = ROW, DL = COL
        PUSH AX
        PUSH BX
        
        MOV AH, 2
        MOV BH, 0
        INT 10H
        
        POP BX
        POP AX
        RET
    GOTOXY ENDP

    CLEARSCREEN PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX

        MOV AX, 0600h
        MOV BH, 07
        MOV CX, 0
        MOV DL, 80
        MOV DH, 25
        INT 10H

        MOV AX, 0
        MOV AH, 2
        MOV DX, 0
        INT 10H

        POP DX
        POP CX
        POP BX
        POP AX

        RET
    CLEARSCREEN ENDP

    DELAY PROC ; STATIC DELAY
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX

        MOV CX, 2H
        MOV DX, 3280H
        MOV AH, 86h
        INT 15h

        POP DX
        POP CX
        POP BX
        POP AX

        RET
    DELAY ENDP

    READCHAR PROC ;AX USED
        MOV AH, 00H
        INT 16H

        RET
    READCHAR ENDP

    WRITECHAR PROC ;AX USED
        MOV AH, 2
        INT 21H

        RET
    WRITECHAR ENDP

    ;game proc

END MAIN