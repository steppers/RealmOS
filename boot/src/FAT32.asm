;;--------------------------------------
;   Basic FAT32 reader
;   Uses:   0x0500-0x06FF = FAT sector
;           0x0700-0x08FF = Cur. Cluster
;;--------------------------------------

fat_init:
    ;call calcFirstDataSector
    ;call calcRootDirSector
    ;call loadRootDir
    ret

fat_readFile:
    ret

;load the next cluster in the chain
;OUT:   AL = 1-Success, 0-End of file
nextCluster:
    mov eax, dword [var_cluster_next]   ;get next cluster
    cmp eax, 0x0ffffff8 ;check the next cluster number
        jg .end
    mov dword [var_cluster_current], eax
    mov ebx, 4
    call loadCluster


    ;cmp eax, 0x0FFFFFF8    ;;Cluster Checks----------
    ;jge .noCluster
    ;cmp eax, 0x0FFFFFF7
    ;je .badCluster
    ;.noCluster:
    ;.badCluster
    .end:
    ret

loadRootDir:
    mov bx, word [FAT_NUM_RESERVED_SECTORS]
    call loadFATSector

    mov eax, dword [FAT_ROOT_CLUSTER]
    mov dword [var_cluster_current], eax
    call loadCluster
    ret

;IN: EBX = FAT Sector
loadFATSector:
    xor eax, eax
    mov es, eax
    mov cx, FAT_LOCATION
    call loadSector
    ret

;IN: EAX = Cluster
loadCluster:
    call cluster2sector
    mov ebx, eax
    xor eax, eax
    mov es, eax
    mov cx, CUR_CLUSTER_LOCATION
    call loadSector
    ret

calcFirstDataSector:
    xor eax, eax
    mov al, byte [FAT_NUM_TABLES]
    mov ebx, dword [FAT_SECTORS_PER_FAT]
    mul ebx ;table_count * fat_size
    xor ebx, ebx
    mov bx, word [FAT_NUM_RESERVED_SECTORS]
    add eax, ebx
    mov dword [var_first_data_sector], eax
    ret

calcRootDirSector:
    mov eax, dword [FAT_ROOT_CLUSTER]
    call cluster2sector
    mov dword [var_root_dir_sector], eax
    ret

;IN:        EAX = cluster
;OUT:       EAX = sector
cluster2sector:
    sub eax, 2  ;cluster = cluster - 2
    xor ebx, ebx    ;clear ebx
    mov bl, byte [FAT_SECTORS_PER_CLUSTER]
    mul ebx     ;cluster = (cluster - 2) * sector_per_cluster
    add eax, dword [var_first_data_sector]
    ret

;IN:    EAX - High word of 64-bit sector
;       EBX - Low word of 64-bit sector
;       ES:CX - Destination RAM address [SEG16 : OFFSET16]
loadSector:
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


;Variables start ------------------------
var_cluster_current:
    dd 0
var_cluster_next:
    dd 0xffffffff
var_cluster_first_sec:
    dd 0
var_first_data_sector:
    dd 0
var_root_dir_sector:
    dd 0
;Variables end --------------------------

;Constants start ------------------------
FAT_LOCATION EQU 0x0500
CUR_CLUSTER_LOCATION EQU 0x0700

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
;Constants end---------------------------
