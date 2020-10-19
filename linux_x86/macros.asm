; macros.asm included from ldca.asm
;
; Author: M. Mert Yildiran <me@mertyildiran.com>
; Licensed under the GNU General Public License v2.0

%macro rndNum 2
                rdtsc                           ; Generate random bytes using CPU's clock (Read Time-Stamp Counter)
                xor     edx, edx                ; there's no division of eax
                mov     ecx, %2 - %1 + 1        ; possible values
                div     ecx                     ; edx:eax / ecx --> eax quotient, edx remainder
                mov     eax, edx                ; eax = [0, %1 - 1]
                add     eax, %1                 ; eax = [%1, %2]
%endmacro
