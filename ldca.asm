BITS 32
                org     0x00010000

ehdr:                                           ; Elf32_Ehdr
                db      0x7F, "ELF", 1, 1, 1, 0 ; e_ident
        times 8 db      0
                dw      2                       ; e_type
                dw      3                       ; e_machine
                dd      1                       ; e_version
                dd      _start                  ; e_entry
                dd      phdr - $$               ; e_phoff
                dd      0                       ; e_shoff
                dd      0                       ; e_flags
                dw      ehdrsize                ; e_ehsize
                dw      phdrsize                ; e_phentsize
                dw      1                       ; e_phnum
                dw      0                       ; e_shentsize
                dw      0                       ; e_shnum
                dw      0                       ; e_shstrndx

ehdrsize        equ     $ - ehdr

phdr:                                           ; Elf32_Phdr
                dd      1                       ; p_type
                dd      0                       ; p_offset
                dd      $$                      ; p_vaddr
                dd      $$                      ; p_paddr
                dd      filesize                ; p_filesz
                dd      filesize                ; p_memsz
                dd      7                       ; p_flags
                dd      0x1000                  ; p_align

phdrsize        equ     $ - phdr

fname: times 49 db      '0'                     ; Apparently 49 is the filename length limit
                dw      0

program:        mov     eax, 4                   ; __NR_write from asm/unistd_32.h (32-bit int 0x80 ABI)
                mov     ebx, 1                   ; stdout fileno
                push    'A'
                mov     ecx, esp                 ; esp now points to your char
                mov     edx, 1                   ; edx should contain how many characters to print
                int     0x80                     ; sys_write(1, "A", 1)
                add     esp, 4
                ret

do_inc_fname:   inc     byte [ebx]
                ret

loop_inc_fname: cmp     byte [ebx], 57
                jne     do_inc_fname
                mov     byte [ebx], '0'
                dec     ebx
                call    loop_inc_fname
                ret

inc_fname:      mov     ebx, fname
                add     ebx, 48
                call    loop_inc_fname
                mov     ebx, fname
                ret

replicate:      mov     eax, 5                   ; 5 = open syscall
                call    inc_fname
                mov     ecx, 65                  ; 65 = O_WRONLY | O_CREAT
                mov     edx, 777q
                int     0x80
                lea     edx, [filesize]
                xchg    eax, ebx
                xchg    eax, ecx
                mov     cl, 0
                mov     al, 4                   ; 4 = write syscall
                int     0x80
                ret

exit:           mov     bl, 0
                mov     al, 1                   ; 1 = exit syscall
                int     0x80

_start:         call    program
                call    replicate
                call    exit

filesize        equ     $ - $$
