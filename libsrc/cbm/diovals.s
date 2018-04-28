;
; Constants and variables that are shared by many of the DIO functions.
;
; 2018-04-25, Greg King
;

        .include        "diovals.inc"
        .include        "filedes.inc"


.bss

; Currently active device file number; used internally (reduces code size).

dhandle:
        .res    1

; These tables are indexed by dhandle.

dioNumTracks:
        .res    MAX_FDS         ; number of tracks on discoverred disks
dioMaxSector:
        .res    MAX_FDS         ; maximum sector number, 0 -> use map

dioForMap_l:
        .res    MAX_FDS         ; pointer to format map
dioForMap_h:
        .res    MAX_FDS

dioSectCount_l:
        .res    MAX_FDS         ; number of sectors on variable-tracks disks
dioSectCount_h:
        .res    MAX_FDS
