[BITS 16]
[org 0x8000]
bl_stage2Reset:
bl_initStack:
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, CONST_STACK_START

bl_main:
    call bl_clearScreen

    mov si, var_bootloaderName
    call bl_printStr
    mov si, var_stage2Confirmation
    call bl_printStr

    call bl_hang

bl_loadKernel:

bl_passToKernel:

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

bl_hang:
    jmp bl_hang

;; Boot code end ------------------------------------

;; Boot data start ----------------------------------
var_terminal_x:
    db 0

var_terminal_y:
    db 2

var_bootloaderName:
    db "RealmOS-Bootloader-V0.1", 0

var_stage2Confirmation:
    db "Stage 2 Loaded!", 0

var_errorMessage:
    db "Error!", 0
;; Boot data end ------------------------------------

;; Constants Start ----------------------------------
CONST_STACK_START EQU 0x8000
CONST_TEXT_MEM EQU 0xb800
;; Constant end -------------------------------------
