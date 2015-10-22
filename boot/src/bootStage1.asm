; bootFAT32.asm
[BITS 16]
[ORG 0x7C5A]

;; Boot code begin ----------------------------------
bl_reset:
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, CONST_STACK_START

    call fat_init
    jmp hang

    ;mov si, var_boot_image_filename
    ;call fat_getRootFile

    ;cmp eax, 0
    ;je bl_error

    ;call fat_cluster2sector

    ;mov ebx, eax    ;Load the second stage at 0x8000
    ;;xor eax, eax
    ;;mov es, eax
    ;;mov cx, CONST_STAGE_2_START
    ;;call bl_loadSector

;bl_passToStage2:
    ;jmp CONST_STAGE_2_START

;fat_loadRootDir:
;    mov ebx, dword [var_fat_rootDirSector]    ;Load the root dir into 0x8000
;    xor eax, eax
;    mov es, eax
;    mov cx, 0x8000
;    call bl_loadSector
;    ret

;IN: SI = filename
;OUT: EAX = fileStartCluster
;fat_getRootFile:
;    xor eax, eax    ;Clear eax
;    push eax
;    push si
;    mov di, si
;    file_scan:
;        mov ebx, 64
;        mul ebx     ;eax = eax * 64
;        add eax, 0x8020 ;Add the root dir offset
;        mov si, ax
;        mov ecx, 0
;        fileLoop:
;            lodsb
;            cmp al, 0
;                je fileNoFile
;            cmp al, 0xe5
;                je fileNextFile
;            cmp al, byte [di]
;                jne fileNextFile
;            inc di
;            inc cl
;            cmp cl, 11
;                je fileReturn
;                jne fileLoop
;
;        fileNoFile:
;            xor eax, eax
;            ret
;        fileNextFile:
;            pop dx
;            pop eax
;            inc eax
;            push eax
;            push dx
;            jmp file_scan
;        fileReturn:
;            pop dx
;
;            pop eax     ;Calc offset again
;            mov ebx, 64
;            mul ebx
;            add eax, 0x8020
;
;            xor ebx, ebx    ;clear ebx
;            mov bx, word [eax + 20]
;            shl ebx, 16
;            mov bx, word [eax + 26]
;            mov eax, ebx
;            ret
;
;----------------------------------
;dochar:   call cprint         ; print one character
;sprint:   lodsb      ; string char to AL
;    cmp al, 0
;    jne dochar   ; else, we're done
;    add byte [var_ypos], 1   ;down one row
;    mov byte [var_xpos], 0   ;back to left
;    ret

;cprint:   mov ah, 0x0F   ; attrib = white on black
;   mov cx, ax    ; save char/attribute
;   movzx ax, byte [var_ypos]
;   mov dx, 160   ; 2 bytes (char/attrib)
;   mul dx      ; for 80 columns
;   movzx bx, byte [var_xpos]
;   shl bx, 1    ; times 2 to skip attrib
;
;   mov di, 0        ; start of video ;memory
;   add di, ax      ; add y offset
;   add di, bx      ; add x offset
;
;   mov ax, cx        ; restore ;char/attribute
;   stosw              ; write ;char/attribute
;   add byte [var_xpos], 1  ; advance to ;right;

;   ret

;------------------------------------

;bl_error:
;    mov ax, 0xb800   ; text video memory
;    mov es, ax
;    mov si, var_err_string
;    call sprint
    hang:
    jmp hang

%include "boot/src/FAT32.asm"

;; Boot code end ------------------------------------

;; Boot data start ----------------------------------
;var_xpos:
;    db 0
;
;var_ypos:
;    db 0
;
;var_err_string:
;    db "Error!", 0
;
;var_boot_image_filename:
    ;db "BOOT    IMG"
;
;var_fat_firstDataSector:
    ;dd 0
;
;var_fat_rootDirSector:
    ;dd 0
;
;var_fat_firstFatSector:
    ;dw 0
;
;var_currentCluster:
    ;dd 2            ;Current cluster
    ;dd 0xffffffff   ;Next cluster
    ;dd 0            ;Cluster first sector
;
;; Boot data end ------------------------------------

;; Constants Start ----------------------------------
CONST_STACK_START EQU 0x7c00
;CONST_STAGE_2_START EQU 0x8000

;; FAT32 Constants
;CONST_FAT_BYTES_PER_SECTOR EQU 0x7c00 + ;11
;CONST_FAT_SEC_PER_CLUSTER EQU 0x7c00 + 13
;CONST_FAT_NUM_RESERVED_SECTORS EQU 0x7c00 ;+ 14
;CONST_FAT_TABLE_COUNT EQU 0x7c00 + 16
;CONST_FAT_TOTAL_SECS_SMALL EQU 0x7c00 + ;19
;CONST_FAT_TOTAL_SECS_LARGE EQU 0x7c00 + ;32
;CONST_FAT_SEC_PER_FAT EQU 0x7c00 + 36
;CONST_FAT_ROOT_DIR_CLUSTER EQU 0x7c00 + ;44
;CONST_FAT_DRIVE_NUMBER EQU 0x7c00 + 64
;CONST_FAT_VOL_LABEL EQU 0x7c00 + 71
;; Constant end -------------------------------------

;; Pad and add the boot signature
times 420-($-$$) db 0
dw 0xAA55
