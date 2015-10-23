[BITS 16]
[org 0x8000]
stage2Entry:
    ;Finish loading stage 2
    mov eax, 512
    xor ecx, ecx
    mov cl, byte [FAT_SECTORS_PER_CLUSTER]
    mul ecx
    mov ebx, 0x8000
    add ebx, eax
    mov eax, dword [var_cluster_next]
    cmp eax, 0x0FFFFFFE ;Jump if we have no more to load!
        jge reset_stack
    .load:  ;load cluster till we reach the end of the file
    push ebx
    mov ecx, ebx

    call fat_loadCluster

    pop ebx
    mov eax, 512
    xor ecx, ecx
    mov cl, byte [FAT_SECTORS_PER_CLUSTER]
    mul ecx
    add ebx, eax
    mov eax, dword [var_cluster_next]
    cmp eax, 0x0FFFFFFE
        jl .load
    jmp reset_stack

    %include "boot/src/stage2/boot2Load.asm" ;Include the functions from stage 1 we need to reuse.

hang:
    jmp hang

reset_stack:
    ;Reset the stack
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, CONST_STACK_START

stage2_main:
    call bl_clearScreen

    mov si, var_bootloaderName
    call bl_printStr
    mov si, var_stage2Confirmation
    call bl_printStr

    call hang

bl_printStr:
    mov ax, CONST_TEXT_MEM
    mov es, ax

    printStr_newChar:
        lodsb
        cmp al, 0
        je printStr_end

    printStr_printChar:
        mov ah, 0x0c
        mov cx, ax
        movzx ax, byte [var_terminal_y]
        mov dx, 160
        mul dx
        movzx bx, byte [var_terminal_x]
        shl bx, 1

        mov di, 0
        add di, ax
        add di, bx

        mov ax, cx
        stosw
        add byte [var_terminal_x], 1
        jmp printStr_newChar

    printStr_end:
    add byte [var_terminal_y], 1
    mov byte [var_terminal_x], 0
    ret

bl_clearScreen:
    mov byte [var_terminal_y], 0
    mov byte [var_terminal_x], 0
    mov ax, CONST_TEXT_MEM
    mov es, ax
    mov di, 0
    mov cx, 80 * 25
    mov ax, 0
    cld
    rep stosw
    ret

;; Boot code end ------------------------------------

;; Boot data start ----------------------------------
var_terminal_x:
    db 0
var_terminal_y:
    db 2

    db "88888888888888888888888888888888788888888888888888888888888878"
    db "88888888888888888888888888888888788888888888888888888888888878"
    db "88888888888888888888888888888888788888888888888888888888888878"
    db "88888888888888888888888888888888788888888888888888888888888878"
    db "88888888888888888888888888888888788888888888888888888888888878"
    db "88888888888888888888888888888888788888888888888888888888888878"
    db "88888888888888888888888888888888788888888888888888888888888878"
    db "88888888888888888888888888888888788888888888888888888888888878"
    db "88888888888888888888888888888888788888888888888888888888888878"
    db "88888888888888888888888888888888788888888888888888888888888878"
    db "88888888888888888888888888888888788888888888888888888888888878"
    db "88888888888888888888888888888888788888888888888888888888888878"
    db "88888888888888888888888888888888788888888888888888888888888878"
    db "88888888888888888888888888888888788888888888888888888888888878"

var_bootloaderName:
    db "RealmOS-Bootloader-V0.1", 0
var_errorMessage:
    db "Error!", 0
var_stage2Confirmation:
    db "Stage 2 Loaded!", 0
;; Boot data end ------------------------------------

;;Constants start ---------------------------------------------------
CONST_STACK_START EQU 0x8000
CONST_TEXT_MEM EQU 0xb800
;;Constants end -----------------------------------------------------
