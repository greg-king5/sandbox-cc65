;
; unsigned __fastcall__ dio_query_sectcount (dhandle_t handle);
; /* Return the DIO sector count. */
;
; 2018-04-25, Greg King
;

        .import         pusha, _cc65_umul8x8r16

        .include        "dio.inc"       ; export the function name
        .include        "diovals.inc"
        .include        "errno.inc"
        .include        "filedes.inc"

        .macpack        generic


invalid_fd:
        lda     #EBADF
        jsr     __directerrno   ; returns -1 in .XA
        inx
        txa
        rts                     ; return zero

_dio_query_sectcount:
        cpx     #>$0000
        bne     invalid_fd      ; handle too big
        tay
        bze     invalid_fd      ; handle == NULL
        cpy     #MAX_FDS + 1
        bge     invalid_fd
        stx     __oserror       ; _oserror = 0;

; Check if the file is open.

        lda     fdtab - 1,y     ; get flags for that handle
        and     #LFN_OPEN
        bze     invalid_fd

; If the size already is known, then return it.  Else, compute it.

        lda     dioSectCount_l - 1,y
        ldx     dioSectCount_h - 1,y
        bze     @L1             ; count == 0; it's unknown
        rts

@L1:    tya                     ; pusha changes .Y; move it to .X
        tax
        lda     dioMaxSector - 1,x
        cmp     #$0100 - 1
        beq     noMult
        ;clc                    ; (comparison cleared carry)
        adc     #1              ; sector numbers start at zero
        jsr     pusha
        lda     dioNumTracks - 1,x
        jmp     _cc65_umul8x8r16

; Multiplying by $0100 shifts the low byte to the high byte.

noMult: lda     dioNumTracks - 1,x
        tax
        lda     #<$0000
        rts
