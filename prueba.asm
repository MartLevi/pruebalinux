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
    buf     resb 12    ; hasta 11 + null
    len     resb 1

section .text
global _start

%macro PRN 2
    mov eax, 4
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

%macro RDN 1
    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, %1
    int 0x80
    mov [len], al
%endmacro

_start:
    PRN prompt, prompt_len
    RDN 12

    ; quitar newline si existe
    movzx ecx, byte [len]
    mov edi, ecx
    dec edi
    cmp byte [buf + edi], 10
    jne .no_trim
    mov byte [buf + edi], 0
    mov byte [len], edi
    jmp .check_length

.no_trim:
    mov byte [buf + ecx], 0

.check_length:
    movzx ecx, byte [len]
    cmp ecx, 10
    ja .bad_input

.validate:
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

.check_pal:
    xor esi, esi
    movzx ecx, byte [len]
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
    jmp .exit

.bad_input:
    PRN inv_msg, inv_msg_len

.exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80
