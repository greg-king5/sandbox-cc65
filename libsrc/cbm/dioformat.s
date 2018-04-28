;
; Discover the geometry of the disk in the newly openned DIO drive.
;
; 2018-04-25, Greg King
;

        .export         dio_get_format
        .export         dio1541, dio8050

        .import         push0, push1, pusha0, seek_sector
        .import         tmp4:zp, ptr4:zp

        .include        "diovals.inc"

        .macpack        generic


;--------------------------------------------------------------------------
.rodata

; These arrays describe the geometries of Commodore
; formats that have tracks with different lengths.
; Each number is a running total of the sectors below that track.

dio1541:
        .word   $0000, $0015, $002a, $003f, $0054, $0069, $007e, $0093
        .word   $00a8, $00bd, $00d2, $00e7, $00fc, $0111, $0126, $013b
        .word   $0150, $0165, $0178, $018b, $019e, $01b1, $01c4, $01d7
        .word   $01ea, $01fc, $020e, $0220, $0232, $0244, $0256, $0267
        .word   $0278, $0289, $029a, $02ab

dio8050:
;	...

; (We use .proc here because it defines both a label and a scope.)

.proc   knownTracks
        .byte   35              ; 4040, 1541
        .byte   35 * 2          ; 1571
        .byte   77              ; 8050
        .byte   77 * 2          ; 8250
.endproc

drive_l:
        .byte   <dio1541
        .byte   <dio1541
        .byte   <dio8050
        .byte   <dio8050
drive_h:
        .byte   >dio1541
        .byte   >dio1541
        .byte   >dio8050
        .byte   >dio8050


;--------------------------------------------------------------------------
.code

dio_get_format:

; Find the disk's maximum track number.

        lda     #%10000000
        sta     tmp4            ; bit shift register
        asl     a
        sta     ptr4            ; start at zero

@L1:    lda     ptr4
        ora     tmp4
        sta     ptr4+1
        jsr     pusha0          ; push test track
        jsr     push0           ; push sector = 0
        lda     #'1'            ; direction = read
        jsr     seek_sector
        bze     @L2             ; track # exists; save it
        cmp     #66
        beq     @L3             ; invalid track #; try a lower one
        rts                     ; return DOS error # to caller

@L2:    lda     ptr4+1
        sta     ptr4

@L3:    lsr     tmp4
        bnz     @L1

        ldy     dhandle
        lda     ptr4
        sta     dioNumTracks,y

        ldx     #.sizeof(knownTracks) - 1
@L4:    cmp     knownTracks,x
        beq     varFormat
        dex
        bpl     @L4

; No match; all of the tracks have the same length; find it.

        lda     #%10000000
        sta     tmp4            ; bit shift register
        asl     a
        sta     ptr4            ; start at zero

@L5:    jsr     push1           ; push track = 1
        lda     ptr4
        ora     tmp4
        sta     ptr4+1
        jsr     pusha0          ; push test sector
        lda     #'1'            ; direction = read
        jsr     seek_sector
        bze     @L6             ; sector # exists; save it
        cmp     #66
        beq     @L7             ; invalid sector #; try a lower one
        rts                     ; return DOS error # to caller

@L6:    lda     ptr4+1
        sta     ptr4

@L7:    lsr     tmp4
        bnz     @L5

        ldy     dhandle
        lda     ptr4
        sta     dioMaxSector,y

        lda     #$00                    ; no error
        sta     dioSectCount_h,y        ; number of sectors isn't known yet
        rts

; The tracks have various lengths.  Memorize the format and size of the disk.

varFormat:
        lda     drive_l,x
        sta     dioForMap_l,y
        sta     ptr4
        lda     drive_h,x
        sta     dioForMap_h,y
        sta     ptr4+1

        tya
        tax                     ; .X = dhandle
        lda     dioNumTracks,x
        lsr     a
        bcc     @L1
        rol     a               ; single-sided, double the array offset
@L1:    rol     a
        tay
        lda     (ptr4),y
        sta     dioSectCount_l,x
        iny
        lda     (ptr4),y
        sta     dioSectCount_h,x

        lda     #0              ; use map for variable track-length drives
        sta     dioMaxSector,x
        rts
