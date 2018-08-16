;
; 2014-07-11, Greg King
;
; #include <time.h>
; void __fastcall__ _cbm_setdate (const struct tm* tm);
; /* Copies a broken-down date into an internal structure
; ** that is used by time() in some Commodore libraries.
; */
;

        .export         __cbm_setdate

.if .defined(__C128__) || .defined(__C64__) || .defined(__CBM510__) || .defined(__CBM610__)

        .import         current_tm_, pushax, swapstk, _memcpy

        .include        "time.inc"

__cbm_setdate:
        jsr     pushax
        lda     #<current_tm_
        ldx     #>current_tm_
        jsr     swapstk
        jsr     pushax
        lda     #<.sizeof(tm)
        ldx     #>.sizeof(tm)
        jmp     _memcpy         ; current_tm = tm;

.else

__cbm_setdate:
        rts

.endif
