[BITS 16]
;;DEBUG*****************************
;mov si, var_boot_image_filename
;call print_str
;jmp hang
;;**********************************

;;FAT Subroutines start ---------------------------------------------
fat_init:   ;0x7C73
    ;calculate var_base_data_sector
    mov eax, dword [FAT_SECTORS_PER_FAT]
    xor ebx, ebx
    mov bl, byte [FAT_NUM_TABLES]
    mul ebx
    xor ebx, ebx
    mov bx, word [FAT_NUM_RESERVED_SECTORS]
    add eax, ebx
    mov dword [var_base_data_sector], eax

    ;Load the root directory
    mov eax, 2              ;Root starts in cluster 2
    mov cx, CURRENT_CLUSTER_LOCATION
    call fat_loadCluster
    ret

fat_getBootFile:
    ;Get the first fileName in the loaded cluster
    mov eax, CURRENT_CLUSTER_LOCATION
    add eax, 32 ;Offset to shortfilename

    .loop:
    push eax
    mov bl, byte [eax]     ;Ensure we haven't reached the end of the directory
    cmp bl, 0
        je .fail
    mov si, ax
    call fat_isBootFile
    cmp al, 1
        je .found

    .checkNextEntry:
        pop ebx
        add ebx, 64 ;Point to the next entry
        xor eax, eax
        mov al, byte [FAT_SECTORS_PER_CLUSTER]
        mov ecx, 512
        mul ecx
        add eax, CURRENT_CLUSTER_LOCATION
        ;;ASSUMES THAT THE CLUSTER SIZE IS 512! *************************
        cmp ebx, eax;****************************************************
        ;;**************************No it doesn't!********************
        mov eax, ebx
            jl .loop

    .loadNextCluster:
        push eax
        mov ebx, dword [var_cluster_next]
        cmp ebx, 0x0FFFFFFE
            jge .fail
        mov eax, ebx
        mov cx, CURRENT_CLUSTER_LOCATION
        call fat_loadCluster
        pop eax
        jmp fat_getBootFile

    .fail:
        mov si, var_err_string
        call print_str
        jmp hang

    .found:     ;Load it!
        pop eax
        ;Get the cluster
        mov bx, word [eax + 20]
        shl ebx, 16
        mov bx, word [eax + 26]
        mov eax, ebx
        mov cx, STAGE_2_LOCATION
        call fat_loadCluster
        jmp STAGE_2_LOCATION    ;;JUMP!!!!!!!!!!

;IN:    SI = Filename (8 bytes + 3 bytes ext)
;OUT:   AL = (1:true), (0:false)
fat_isBootFile:
    mov ebx, var_boot_image_filename
    mov cl, 0
    .loop:
        lodsb
        inc cl
        cmp cl, 11
            je .success
        mov dl, byte [ebx]
        inc ebx
        cmp al, dl
            je .loop
    .fail:
        mov al, 0
        ret
    .success:
        mov al, 1
        ret

;IN: EAX = Cluster => Sector of cluster
fat_cluster2sector:
    sub eax, 2
    xor ebx, ebx
    mov bl, byte [FAT_SECTORS_PER_CLUSTER]
    mul ebx
    add eax, dword [var_base_data_sector]
    ret

;Returns the table sector and offset of a cluster
;IN:    EAX = Cluster
;OUT:   EAX = TableSector
;       EBX = Offset to table entry
fat_cluster2table:
    ;FATindex = cluster / entries_per_fat_sector
    ;offset = cluster % entries_per_fat_sector
    mov ebx, ENTRIES_PER_FAT_SECTOR
    ;xor edx, edx    ;div uses edx so clear it
    div ebx     ;quotient in eax, remainder in edx
    mov ebx, edx
    ;return sector = FATindex + num_reserved_sectors
    xor edx, edx
    mov dx, word [FAT_NUM_RESERVED_SECTORS]
    add eax, edx
    shl ebx, 2
    ret

;Returns the value of the given table entry
;IN:    EAX = Table sector
;       EBX = Offset
;OUT:   EAX = Entry
fat_getTableEntry:
    ;Load the table sector at 0x0500
    push ebx
    mov ebx, eax
    xor eax, eax
    mov cx, CURRENT_FAT_LOCATION
    call readSector
    ;Address = 0x0500 + offset
    pop ebx
    add ebx, CURRENT_FAT_LOCATION
    ;EAX = dword [Address]
    mov eax, dword [ebx]
    ret

;Loads the cluster at the destination address
;IN:    EAX = Cluster ID
;       CX = Destination Address
fat_loadCluster:    ;0x7D86
    push eax    ;Push cluster id
    call fat_cluster2sector ;Sector in eax

    mov dl, byte [FAT_SECTORS_PER_CLUSTER] ;Sectors per cluster in dx
    .loop:
    push dx ;push sectors per cluster (our counter)
    mov ebx, eax    ;Move sector to ebx
    push ebx        ;Push the sector
    xor eax, eax    ;Clear eax
    call readSector ;Read sector at eax:ebx
    pop eax         ;Pop the sector
    inc eax         ;Inc the sector
    pop dx          ;Pop the sectors per cluster (our counter)
    dec dl          ;Decrement the sectors per cluster (our counter)
    cmp dl, 0       ;Break if we have loaded all sectors
        jne .loop

    pop eax ;Pop the newly loaded cluster id
    mov dword [var_cluster_current], eax    ;Store the cluster id
    call fat_cluster2table                  ;Convert to cluster fat table entry location
    call fat_getTableEntry                  ;Get the next cluster in the chain
    mov dword [var_cluster_next], eax       ;Store the next cluster in the chain
    ret

;;FAT Subroutines end -----------------------------------------------

;;Read Sector -------------------------------------------------------
;IN:    EAX = Sector address High
;       EBX = Sector address Low
;       ES:CX = Destination address
readSector:
    mov di, sp  ;Save the initial stack pointer
    ; Push the Data Address Packet
    push eax        ;High sector 64
    push ebx        ;Low sector 64
    push es         ;Destination segment
    push cx         ;Destination index
    push byte 1     ;1 Sector
    push byte 16    ;16 byte packet

    mov si, sp  ;Pass DAP start address
    mov dl, [FAT_DRIVE_NUM]
    mov ah, 0x42
    int 0x13    ;Do read

    mov sp, di  ; Restore stack back to state before read
    ret

;;Print string ------------------------------------------------------
;IN: SI = Pointer to null terminated string
print_str:
    lodsb                                       ; load next character
    or      al, al                              ; test for NUL character
    jz      .DONE
    mov     ah, 0x0E                            ; BIOS teletype
    int     0x10                                ; invoke BIOS
    jmp     print_str
    .DONE:
    ret

;;Variables start ---------------------------------------------------
var_err_string:
    db "Er", 0
var_boot_image_filename:
    db "BOOT    IMG"
var_base_data_sector:;0x7DEB
    dd 0
var_base_fat_sector:;0x7DEF
    dd 0

;;Current Cluster data
var_cluster_current:;0x7DF3
    dd 0xffffffff
var_cluster_next:   ;0x7DF7
    dd 0xffffffff
var_cluster_size:
    db 1
;;Variables end -----------------------------------------------------

;;Constants start ---------------------------------------------------
ENTRIES_PER_FAT_SECTOR EQU 128  ;128 4byte entries per sector
CURRENT_FAT_LOCATION EQU 0x0500
CURRENT_CLUSTER_LOCATION EQU 0x0700
STAGE_2_LOCATION EQU 0x8000

FAT_BYTES_PER_SECTOR EQU 0x7c00 + 11
FAT_SECTORS_PER_CLUSTER EQU 0x7c00 + 13
FAT_NUM_RESERVED_SECTORS EQU 0x7c00 + 14
FAT_NUM_TABLES EQU 0x7c00 + 16
FAT_NUM_DIR_ENTRIES EQU 0x7c00 + 17
FAT_NUM_SECTORS_SMALL EQU 0x7c00 + 19
FAT_MEDIA_DECRIPTOR_TYPE EQU 0x7c00 + 21
FAT_SECTORS_PER_TRACK EQU 0x7c00 + 24
FAT_NUM_SIDES EQU 0x7c00 + 26
FAT_NUM_HIDDEN_SECTORS EQU 0x7c00 + 28
FAT_NUM_SECTORS_LARGE EQU 0x7c00 + 32

FAT_SECTORS_PER_FAT EQU 0x7c00 + 36
FAT_FLAGS EQU 0x7c00 + 40
FAT_ROOT_CLUSTER EQU 0x7c00 + 44
FAT_DRIVE_NUM EQU 0x7c00 + 64
;;Constants end -----------------------------------------------------
