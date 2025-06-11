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
    buf     resb 100     ; suficiente para manejar exceso de entrada
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
    mov [len], eax
%endmacro

_start:
    PRN prompt, prompt_len
    RDN 100  ; leer hasta 100 caracteres

    ; Buscar el salto de línea y contar solo hasta ahí
    xor ecx, ecx       ; ecx = índice
    xor edi, edi       ; edi = número de caracteres válidos

.find_nl:
    cmp ecx, [len]
    jge .bad_input     ; si no hay salto de línea, es inválido
    mov al, [buf + ecx]
    cmp al, 10         ; '\n'
    je .check_length
    inc edi
    inc ecx
    jmp .find_nl

.check_length:
    cmp edi, 0
    je .bad_input
    cmp edi, 10
    ja .bad_input
    mov [len], edi
    mov byte [buf + edi], 0  ; null-terminate

    ; Validar dígitos
    xor esi, esi
.validate_digits:
    cmp esi, edi
    jge .check_pal
    mov al, [buf + esi]
    sub al, '0'
    cmp al, 9
    ja .bad_input
    inc esi
    jmp .validate_digits

.check_pal:
    xor esi, esi
    mov ecx, edi
    dec ecx
    mov ebx, ecx

.loop:
    cmp esi, ebx
    jge .is_pal
    mov al, [buf + esi]
    mov dl, [buf + ebx]
    cmp al, dl
    jne .not_pal
    inc esi
    dec ebx
    jmp .loop

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
