; Last Digital Common Ancestor (LDCA)
;
; Self-replicating, self-modifying Assembly program that can evolve into
; every possible computer program in the universe.
;
; Author: M. Mert Yildiran <me@mertyildiran.com>
; Licensed under the GNU General Public License v2.0
;
; Target architecture: Linux x86
; Compile with: nasm -f bin -o 0000000000000000000000000000000000000000000000000 ldca.asm

%include "macros.asm"

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

programstart    equ     $

program:        mov     eax, 4                  ; 5 = sys_write
                mov     ebx, 1                  ; 1 = stdout
                push    'A'
                mov     ecx, esp                ; esp now points to your char
                mov     edx, 1                  ; edx should contain how many characters to print
                int     0x80                    ; sys_write(1, 'A', 1)
                add     esp, 4
                ret

programend      equ     $
programsize     equ     programend - programstart

do_inc_fname:   inc     byte [ebx]              ; Increment the filename
                ret

loop_inc_fname: cmp     byte [ebx], 57          ; Compare char to 9
                jne     do_inc_fname            ; if it's not 9, jump
                mov     byte [ebx], '0'         ; if it's 9, replace it with 0
                dec     ebx                     ; increase the digit
                call    loop_inc_fname          ; repeat
                ret

inc_fname:      mov     ebx, fname              ; Move the pointer to filename into ebx
                add     ebx, 48                 ; move cursor into the last character of the filename
                call    loop_inc_fname          ; Increment the filename
                mov     ebx, fname              ; Fix ebx into beginning of filename
                ret

kill_parent:    mov     eax, 64                 ; 64 = sys_getppid
                int     0x80                    ; sys_getppid()

                mov     ebx, eax                ; Move parent PID to ebx
                mov     eax, 37                 ; 37 = sys_kill
                mov     ecx, 9                  ; 9 = SIGKILL
                int     0x80                    ; sys_kill(PID, SIGKILL)
                ret

run:            mov     eax, 11                 ; 11 = sys_execve
                mov     ebx, fname              ; command
                mov     ecx, 0                  ; no arguments
                mov     edx, 0                  ; environment = NULL
                int     0x80                    ; sys_execve(fname, fname, NULL)
                ret

fork:           mov     eax, 2                  ; 2 = sys_fork
                int     0x80                    ; sys_fork()

                cmp     eax, 0                  ; if eax is zero we are in the fork
                jz      run                     ; jump to run if eax is zero
                mov     ebx, eax                ; Move child PID to ebx
                mov     eax, 7                  ; 7 = sys_waitpid
                mov     ecx, 0                  ; status storage = NULL
                mov     edx, 0                  ; options = WEXITED
                int     0x80                    ; sys_waitpid(PID, NULL, WEXITED)

                call    replicate               ; if child process died replicate again
                ret

rand_byte:      mov     ebx, program            ; Move the cursor to the beginning of the program
                rndNum  0, programsize - 1      ; generate random number between 0 and "programsize"
                add     ebx, eax                ; go N instructions forward (N = random offset in the eax register)
                rdtsc                           ; generate random bytes using CPU's clock (Read Time-Stamp Counter)
                mov     byte [ebx], al          ; replace the byte with a randomly generated byte
                ret

left_shift:     mov     ebx, eax                ; Copy delete offset to ebx
                inc     ebx                     ; increment ebx
                mov     ecx, [ebx]              ; move the byte pointed by ebx into ecx (left shift - first half)
                mov     byte [eax], cl          ; move the byte pointed by ecx into eax (left shift - second half)
                inc     eax                     ; go one byte forward
                cmp     eax, programend - 1     ; compare eax to filesize
                jng     left_shift              ; if eax not greater than the filsize then repeat
                ret

shrink:         mov     eax, 1                  ; Delete offset, between 1 and "current programsize"
                add     eax, programstart       ; add programstart offset to delete offset to find the true location
                call    left_shift              ; left shift the whole program starting from the delete offset
                dec     esi                     ; decrement the programsize
                dec     edi                     ; decrement the filesize
                ret

right_shift:    mov     ecx, [ebx]              ; Move the byte pointed by ebx into ecx (right shift - first half)
                mov     [eax], ecx              ; move the byte pointed by ecx into eax (right shift - second half)
                dec     eax                     ; decrement eax (filesize + grow size)
                dec     ebx                     ; decrement ebx (filesize)
                cmp     ebx, programend         ; compare ebx to "programend"
                jge     right_shift             ; if we did not reach to program symbol's end then continue shifting
                ret

fill_gap:       inc     ebx                     ; Increment starting offset
                rdtsc                           ; generate random bytes using CPU's clock (Read Time-Stamp Counter)
                mov     byte [ebx], al          ; replace the byte with a randomly generated byte
                mov     ecx, programstart       ; program's start
                add     ecx, esi                ; program's start + new programsize = new program's end
                cmp     ebx, ecx                ; compare cursor with the new program's end
                jl      fill_gap                ; if it's less than that then repeat
                ret

grow:           rndNum  1, 256                  ; Grow size, between 1 byte and 256 bytes
                push    eax                     ; push the grow size into the stack
                mov     ebx, edi                ; move filesize into ebx
                mov     ecx, ebx                ; we don't want to change edi
                add     ecx, eax                ; filesize + grow size
                mov     eax, ecx                ; move filesize + grow size into eax
                call    right_shift             ; right shift the whole program starting from the program's end
                pop     eax                     ; retrieve the grow size
                mov     ebx, programend         ; starting offset relative to program's end
                add     esi, eax                ; increase the programsize by grow size
                add     edi, eax                ; increase the filesize by grow size
                call    fill_gap                ; fill the gap created by the right shift
                ret

mutate:         rndNum  0, 99                   ; Generate random number between 0 and 99
                cmp     eax, 80                 ; compare eax (random number) with 80
                jl      rand_byte               ; 80% : change a random byte without growing or shrinking the program
                cmp     eax, 85                 ; compare eax (random number) with 85
                jl      shrink                  ;  5% : shrink the program randomly
                jmp     grow                    ; 15% : grow the program randomly
                ret

replicate:      call    mutate                  ; mutate
                mov     eax, 5                  ; 5 = sys_open
                call    inc_fname               ; increment the filename
                mov     ecx, 65                 ; 65 = O_WRONLY | O_CREAT
                mov     edx, 777q               ; file mode (octal)
                int     0x80                    ; sys_open(fname, 65, 777)
                lea     edx, [edi]              ; load effective address of filesize
                xchg    eax, ebx                ; move the file descriptor in eax to ebx
                xchg    eax, ecx                ; swap eax and ecx
                mov     cl, 0                   ; point out to the beginning of the program by removing first 8 bits
                mov     al, 4                   ; 4 = sys_write
                int     0x80                    ; sys_write(file_descriptor, *content, filesize)
                mov     eax, 6                  ; 6 = sys_close
                int     0x80                    ; sys_close(file_descriptor)
                call    fork                    ; run the offspring with forking
                ; call    run                   ; run the offspring without forking
                ret

exit:           mov     bl, 0                   ; 0 = Exit code
                mov     al, 1                   ; 1 = sys_exit
                int     0x80                    ; sys_exit(0)

_start:         mov     esi, programsize        ; Move programsize into esi (only increment or decrement this)
                mov     edi, filesize           ; move filesize into edi (only increment or decrement this)
                call    program
                call    kill_parent
                call    replicate               ; replicate subroutine must not fail!
                call    exit

filesize        equ     $ - $$
fileend         equ     $
