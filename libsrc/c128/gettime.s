;
; 2009-07-27, Stefan Haubenthal
; 2014-07-11, Greg King
; 2018-08-14, Oliver Schmidt
;
; int clock_gettime (clockid_t clk_id, struct timespec *tp);
;

        .include        "time.inc"
        .include        "c128.inc"
        .include        "get_tv.inc"
        .macpack        generic

        .constructor    inittime
        .export         current_tm_
        .importzp       sreg, tmp1, tmp2
        .import         pushax, pusheax, tosmul0ax, steaxspidx, incsp1, return0


;----------------------------------------------------------------------------

.proc   _clock_gettime

        jsr     pushax
        jsr     pushax

; Get the hour, and freeze the output registers (the time components will stay
; co-ordinated).
        ldx     CIA1_TODHR
        lda     #0
        cpx     #$12                    ; Shift 12 AM to zero
        beq     is0

; Convert from 12-hour format to 24-hour format.
        txa
        bpl     AM
        and     #%01111111
        cmp     #$12                    ; Don't shift 12 PM
        beq     AM
        sed
        clc
        adc     #$12
        cld

AM:     jsr     BCD2dec
is0:    cmp     current_tm_ + tm::tm_hour
        bge     today

; The new time is less than the old time; therefore, the clock must have gone
; past midnight.  Add 24 hours; mktime() will correct the hour and the date.

        ;clc
        adc     #24
today:  sta     current_tm_ + tm::tm_hour
        lda     CIA1_TODMIN
        jsr     BCD2dec
        sta     current_tm_ + tm::tm_min
        lda     CIA1_TODSEC
        jsr     BCD2dec
        sta     current_tm_ + tm::tm_sec
        lda     #<current_tm_
        ldx     #>current_tm_
        jsr     _mktime

        ldy     #timespec::tv_sec
        jsr     steaxspidx      ; Pops address pushed by 2. pushax

        lda     #<(100 * 1000 * 1000 / $10000)
        ldx     #>(100 * 1000 * 1000 / $10000)
        sta     sreg
        stx     sreg+1
        lda     #<(100 * 1000 * 1000)
        ldx     #>(100 * 1000 * 1000)
        jsr     pusheax
        lda     CIA1_TOD10
        ldx     #>$0000
        jsr     tosmul0ax

        ldy     #timespec::tv_nsec
        jsr     steaxspidx      ; Pops address pushed by 1. pushax

        jsr     incsp1
        jmp     return0

.endproc

;----------------------------------------------------------------------------
; dec = (((BCD>>4)*10) + (BCD&0xf))

.proc   BCD2dec

        tax
        and     #%00001111
        sta     tmp1
        txa
        and     #%11110000      ; *16
        lsr                     ; *8
        sta     tmp2
        lsr
        lsr                     ; *2
        adc     tmp2            ; = *10
        adc     tmp1
        rts

.endproc


;----------------------------------------------------------------------------
; Constructor that writes to the 1/10 sec register of the TOD to kick it
; into action. If this is not done, the clock hangs. We will read the register
; and write it again, ignoring a possible change in between.
.segment "ONCE"

.proc   inittime

        lda     CIA1_TOD10
        sta     CIA1_TOD10
        jsr     _get_tv
        cmp     #TV::PAL
        bne     @60Hz
        lda     CIA1_CRA
        ora     #$80
        sta     CIA1_CRA
@60Hz:  rts

.endproc

;----------------------------------------------------------------------------
; The default date is 1970-01-01.

.data

current_tm_:
        .word   0               ; tm_sec
        .word   0               ; tm_min
        .word   0               ; tm_hour
        .word   1               ; tm_mday
        .word   1 - 1           ; tm_mon
        .word   1970 - 1900     ; tm_year
        .word   0               ; tm_wday
        .word   0               ; tm_yday
        .word   .loword(-1)     ; tm_isdst
