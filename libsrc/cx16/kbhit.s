;
; 2021-04-01, Greg King
;
; unsigned char kbhit (void);
; /* Returns non-zero (true) if a typed character is waiting. */
;

        .export         _kbhit

        .include        "cx16.inc"


.proc   _kbhit
        ldy     RAM_BANK        ; (KEY_COUNT is in RAM bank 0)
        stz     RAM_BANK
        lda     KEY_COUNT       ; Get number of characters
        sty     RAM_BANK
        tax                     ; High byte of return (only its zero/nonzero ...
        rts                     ; ... state matters)
.endproc
