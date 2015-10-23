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
    call fat_getBootFile

hang:
    jmp hang

%include "boot/src/stage1/boot1Load.asm"

;;Pad and add the boot signature
times 420-($-$$) db 0
dw 0xAA55
