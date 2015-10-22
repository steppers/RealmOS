[BITS 16]
[ORG 0x7C5A]

boot_reset:
    cli ;disable interrupts
    xor     ax, ax  ;Setup segments
    mov     ds, ax
    mov     es, ax
    mov     fs, ax
    mov     gs, ax
    ;Init stack
    mov     ss, ax
    mov     sp, 0x7c00
    sti ;re-enable interrupts

    call fat_init

    ;;TEST***********************
    mov si, var_boot_image_filename
    call print_str
    ;;***************************

hang:
    jmp hang

;;FAT Subroutines start ---------------------------------------------
fat_init:
    ;calculate var_base_data_sector
    mov eax, dword [FAT_SECTORS_PER_FAT]
    xor ebx, ebx
    mov bl, byte [FAT_NUM_TABLES]
    mul ebx
    xor ebx, ebx
    mov bx, word [FAT_NUM_RESERVED_SECTORS]
    add eax, ebx
    mov dword [var_base_data_sector], eax
    ;calculate var_base_fat_sector
    xor eax, eax
    mov ax, word [FAT_NUM_RESERVED_SECTORS]
    mov dword [var_base_fat_sector], eax
    ;Read the first fat sector into 0x0500
    mov cx, 0x0500
    xor eax, eax
    mov ebx, dword [var_base_fat_sector]
    call readSector
    ;Read the first data sector into 0x0700
    mov cx, 0x0700
    xor eax, eax
    mov ebx, dword [var_base_data_sector]
    call readSector
    ret

;IN:    SI = Filename (8 bytes + 3 bytes ext)
fat_getRootFile:

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
;       BX = Offset to table entry
fat_cluster2table:
    ;offset = cluster % entries_per_fat_sector
    ;FATindex = cluster / entries_per_fat_sector
    ;return sector = FATindex + num_reserved_sectors

;Returns the value of the given table entry
;IN:    EAX = Table sector
;       BX = Offset
;OUT:   EAX = Entry
fat_getTableEntry:
    ;Load the table sector at 0x0500
    ;mov ebx, eax
    ;xor eax, eax
    ;mov cx, 0x0500
    ;call readSector
    ;Address = 0x0500 + offset
    ;EAX = dword [Address]
    ;return

;Loads the cluster at 0x0700
;IN:    EAX = Cluster ID
fat_loadCluster:
    ;push eax
    ;call cluster2sector
    ;mov ebx, eax
    ;clear eax
    ;CX = 0x0700
    ;call readSector
    ;pop eax
    ;var_cluster_current = eax
    ;call fat_cluster2table
    ;call fat_getTableEntry
    ;var_cluster_next = eax
    ;return

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
    push es         ;Destination index
    push cx         ;Destination segment
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
    mov     bh, 0x00                            ; display page 0
    mov     bl, 0x07                            ; text attribute
    int     0x10                                ; invoke BIOS
    jmp     print_str
    .DONE:
    ret

;;Variables start ---------------------------------------------------
var_err_string:
    db "Error!", 0
var_boot_image_filename:
    db "BOOT    IMG"
var_base_data_sector:
    dd 0
var_base_fat_sector:
    dd 0
var_entries_per_fat_sector:
    dd 0

;;Current Cluster data
var_cluster_current:
    dd 2
var_cluster_next:
    dd 0xffffffff
var_cluster_sector:
    dd 0

;;Variables end -----------------------------------------------------

;;Constants start ---------------------------------------------------
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

;;Pad and add the boot signature
times 420-($-$$) db 0
dw 0xAA55
