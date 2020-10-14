BITS 32
                org     0x00010000
                db      0x7F, "ELF", 1, 1, 1, 0 ; e_ident
                dd      0, 0
                dw      2                       ; e_type
                dw      3                       ; e_machine
                dd      1                       ; e_version
                dd      _start                  ; e_entry
                dd      phdr - $$               ; e_phoff
                dd      0                       ; e_shoff
                dd      0                       ; e_flags
                dw      0x34                    ; e_ehsize
                dw      0x20                    ; e_phentsize
phdr:           dd      1                       ; e_phnum       ; p_type
                                                ; e_shentsize
                dd      0                       ; e_shnum       ; p_offset
                                                ; e_shstrndx
                dd      $$                                      ; p_vaddr
fname:          db      'asr', 0                                ; p_paddr
                dd      filesize                                ; p_filesz
                dd      filesize                                ; p_memsz
                dd      7                                       ; p_flags
                dd      0x1000                                  ; p_align
_start:         mov     al, 5                   ; 5 = open syscall
                mov     ebx, fname
                inc     byte [ebx]
                mov     cl, 65                  ; 65 = O_WRONLY | O_CREAT
                mov     dx, 777q
                int     0x80
                lea     edx, [byte ecx + filesize - 65]
                xchg    eax, ebx
                xchg    eax, ecx
                mov     cl, 0
                mov     al, 4                   ; 4 = write syscall
                int     0x80
                mov     bl, 0
                mov     al, 1                   ; 1 = exit syscall
                int     0x80
filesize        equ     $ - $$
