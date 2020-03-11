;
; Stage 1 Bootloader
;
; Called by the MBR. Puts CPU into protected mode.
;
;
;

    section .text.startup

[BITS 16]

    extern checkmem
;
; stage1
;
; Entry point for the stage1 loader. Called by MBR. This should be loaded at
; 0x7e00.
;
    global stage1
stage1:
;    call zeroBSS
    call enableA20

    ; Check how much ram we have.
    push low_mem_amt
    push hi_mem_descriptors
    call checkInstalledRAM
    add sp,4


    call vesaSetup
    ; Set up global descriptor table
    cli
    lgdt [gdt_desc]

    ; Enter protected mode by setting bit 0 of CR0 register
    mov eax,cr0
    or eax,1
    mov cr0,eax
    jmp 0x8:protectedMode ; 8 is offset into GDT, not segment

;
; vesaSetup
;
; Configures the BIOS video to 320x200 graphics mode
vesaSetup:
    push bp
    mov bp,sp ; Create stack frame
    
    mov ax,19

    int 16 
    pop bp
    ret
;
; zeroBSS
;
; Zeros out the BSS section of the stage1 loader.
;
;
    extern _start_bss ; Defined in linker script
    extern _end_bss   ; Defined in linker script
;zeroBSS:
;    push bp
;    mov bp,sp
;    push ax
;    push di
;
;    mov di,_start_bss
;    mov ax,_end_bss
;    
;zeroBSSLoop:
;    mov WORD [di],0
;    add di,2
;    cmp di,ax
;    jl zeroBSSLoop
;
;zeroBSSDone:
;    pop di
;    pop ax
;    leave
;    ret

enableA20:
	push bp
    mov bp,sp
    push ax
	in al, 0x92
	or al, 2
	out 0x92, al
    pop ax
    leave
	ret

; putStr
;
; Prints a NULL-terminated string to the console by calling BIOS Int 0x10
;
; |-------------------------------|
; |          Ptr To String        |
; |-------------------------------|
; |         Return Address        |
; |-------------------------------|
; |          Caller's BP          |
; |-------------------------------|
;
putStr:
    push bp
    mov bp,sp
    push ax
    push si

    ; Load the address of string to print into SI
    mov si,[4+BP]

    ; Set up the registers for a BIOS call to print
    mov ah, 0x0e
    xor bh,bh
    mov bl,7
put_str_loop:
    mov al,[ds:si]
    cmp al,0
    je put_str_done
    int 16
    inc si
    jmp put_str_loop

put_str_done:
    pop si
    pop ax
    pop bp
    ret


;
; checkInstalledRAM
;
; |--------------------------------|
; | Ptr to Low Mem Amount          |
; |--------------------------------|
; | Ptr to Hi Mem Amount           |
; |--------------------------------|
; | Return Address                 |
; |--------------------------------|
; | Base Ptr                       |
; |--------------------------------|
; | Num entries in descriptor list |
; |--------------------------------|
;
checkInstalledRAM:
    push bp
    mov bp,sp
    sub sp,2
; First check how much low mem is availables in kBytes
    clc
    int 0x12
    jc lowMemDetectError

    mov di,[6+bp]
    mov [di],ax
; Next check how much hi mem is available
    mov di, [4+bp]
    xor bx,bx
    mov bx,[-2+bp]            ; Init entry count to zero
    mov edx, 0x0534D4150      ; Place "SMAP" into edx
    mov ax,0xe820             ; BIOS Code to get hi mem descriptors
    mov [es:di + 20], dword 1 ; force a valid ACPI 3.X entry
    mov ecx,24                ; Ask for 24 bytes
    int 0x15                  ; Call BIOS
    jc hiMemDetectionError    ; Err out on carry set

    mov edx, 0x0534D4150      ; Some BIOSes apparently trash this register?
    cmp eax, edx              ; on success, eax must have been reset to "SMAP"
    jne short hiMemDetectionError
    test ebx, ebx             ; ebx = 0 implies list is only 1 entry long (worthless)
    je short hiMemDetectionError
    jmp short jmpin

e820lp:
    mov eax, 0xe820           ; eax, ecx get trashed on every int 0x15 call
    mov [es:di + 20], dword 1 ; force a valid ACPI 3.X entry
    mov ecx, 24               ; ask for 24 bytes again
    int 0x15
    jc short e820f           ; carry set means "end of list already reached"
    mov edx, 0x0534D4150      ; repair potentially trashed register

jmpin:
    jcxz skipent              ; skip any 0 length entries
    cmp cl,20                 ; got a 24 byte ACPI 3.X response?
    jbe notext
    test byte [es:di + 20],1  ; if so: is the "ignore this data" bit clear?
    je short skipent
notext:
    mov ecx, [es:di + 8]      ; get lower uint32_t of memory region length
    or ecx, [es:di + 12]      ; "or" it with upper uint32_t to test for zero
    jz skipent                ; if length uint64_t is 0, skip entry
    inc word [-2+bp]          ; got a good entry: ++count, move to next storage spot
    add di, 24

skipent:
    test ebx, ebx             ; if ebx resets to 0, list is complete
    jne short e820lp

e820f:
    mov di,num_hi_mem_descriptors
    mov ax,[-2,bp]            ; Store number of hi mem desc in the table
    mov [di],ax
    clc
    leave
    ret

hiMemDetectionError:
    push himemerr
    call putStr
    add sp,2
    jmp $

lowMemDetectError:
    push lowmemerr
    call putStr
    add sp,2
    jmp $


[BITS 32]
    extern stage1main
protectedMode:

    ;-------------------------------;
    ;   Set registers       ;
    ;-------------------------------;
 
    mov     ax, 0x10        ; set data segments to data selector (0x10)
    mov     ds, ax
    mov     ss, ax
    mov     es, ax
    mov     esp, 90000h     ; stack begins from 90000h

    jmp stage1main ; Call stage 1 C main


; Global Descriptor Table. Taken from:
; http://www.osdever.net/tutorials/view/the-world-of-protected-mode
; See also:
; https://wiki.osdev.org/GDT_Tutorial
    section .data
gdt:

; NULL Segment
gdt_null:
    dq 0


gdt_code:
    dw 0xffff  ; Limit[15:0]
    dw 0       ; Base[15:0]
    db 0       ; Base[23:16]
    db 10011010b ; Type,privilege level
    db 11001111b
    db 0       ; Base [31:24]

gdt_data:
    dw 0xffff  ; Limit[15:0]
    dw 0       ; Base[15:0]
    db 0       ; Base[23:16]
    db 10010010b ; Type, privilege level
    db 11001111b
    db 0       ; Base[31:24]

gdt_end:

gdt_desc:
    dw gdt_end - gdt - 1
    dd gdt


lowmemerr db 'ERROR detecting low memory',0xd,0xa,0
himemerr db 'ERROR detecting hi memory',0xd,0xa,0

global low_mem_amt
low_mem_amt:
    dw 0

    section .bss
global num_hi_mem_descriptors
num_hi_mem_descriptors:
    resw 1
global hi_mem_descriptors
hi_mem_descriptors:
    resq 100


