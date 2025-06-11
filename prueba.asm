; Palíndromo optimizado en NASM (32 bits Linux)
section .data
    prompt      db "Ingresa numero (max 10 dig): ", 0
    prompt_len  equ $ - prompt

    inv_msg     db "Entrada invalida.",10,0
    inv_msg_len equ $ - inv_msg

    yes_msg     db "Es palindromo.",10,0
    yes_msg_len equ $ - yes_msg

    no_msg      db "No es palindromo.",10,0
    no_msg_len  equ $ - no_msg

section .bss
    buf     resb 11    ; 10 dígitos + null
    len     resb 1     ; longitud: 0-10

section .text
global _start

; ----------------------------
; Syscall wrappers
%macro PRN 2
    mov eax,4
    mov ebx,1
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

%macro RDN 1
    mov eax,3
    mov ebx,0
    mov ecx, buf
    mov edx, %1
    int 0x80
    mov [len], al
%endmacro
; ----------------------------

_start:
    PRN prompt, prompt_len        ; mostrar mensaje
    RDN 11                       ; leer hasta 11 bytes

    ; remover salto de línea si existe
    movzx ecx, byte [len]
    dec ecx
    cmp byte [buf + ecx], 10
    jne .validated
    mov byte [len], cl

.validated:
    ; validar caracteres y determinar len
    xor esi, esi
    movzx ecx, byte [len]

.chk_loop:
    cmp esi, ecx
    jge .check_pal
    mov al, [buf + esi]
    sub al, '0'
    cmp al, 9
    ja .bad_input
    inc esi
    jmp .chk_loop

.bad_input:
    PRN inv_msg, inv_msg_len
    ; Aquí podrías repetir la lectura si quieres
    jmp .start

.check_pal:
    xor esi, esi
    dec ecx
    mov edi, ecx

.pal_loop:
    cmp esi, edi
    jge .is_pal
    mov al, [buf + esi]
    mov bl, [buf + edi]
    cmp al, bl
    jne .not_pal
    inc esi
    dec edi
    jmp .pal_loop

.is_pal:
    PRN yes_msg, yes_msg_len
    jmp .exit

.not_pal:
    PRN no_msg, no_msg_len

.exit:
    mov eax,1
    xor ebx, ebx
    int 0x80

; Para repetir el proceso tras entrada inválida
.start:
    PRN prompt, prompt_len
    RDN 11
    movzx ecx, byte [len]
    dec ecx
    cmp byte [buf + ecx], 10
    jne .validated2
    mov byte [len], cl

.validated2:
    xor esi, esi
    movzx ecx, byte [len]
    jmp .chk_loop
