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
    buf     resb 32    ; mucho espacio para validar
    len     resb 1

section .text
global _start

_start:
    ; Mostrar prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ; Leer entrada
    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 32       ; leer hasta 32 bytes (sobrados para detectar errores)
    int 0x80
    mov [len], eax

    ; Eliminar salto de línea
    mov ecx, eax
    dec ecx
    cmp byte [buf + ecx], 10
    jne .skip_trim
    mov byte [buf + ecx], 0
    mov [len], ecx

.skip_trim:
    ; Verificar si la longitud es mayor a 10
    movzx ecx, byte [len]
    cmp ecx, 10
    ja .invalid

    ; Verificar si todos son dígitos
    xor esi, esi
.check_digit:
    cmp esi, ecx
    jge .check_pal
    mov al, [buf + esi]
    cmp al, '0'
    jl .invalid
    cmp al, '9'
    jg .invalid
    inc esi
    jmp .check_digit

.check_pal:
    xor esi, esi
    mov edi, ecx
    dec edi
.pal_loop:
    cmp esi, edi
    jge .pal_true
    mov al, [buf + esi]
    mov bl, [buf + edi]
    cmp al, bl
    jne .pal_false
    inc esi
    dec edi
    jmp .pal_loop

.pal_true:
    mov eax, 4
    mov ebx, 1
    mov ecx, yes_msg
    mov edx, yes_msg_len
    int 0x80
    jmp .exit

.pal_false:
    mov eax, 4
    mov ebx, 1
    mov ecx, no_msg
    mov edx, no_msg_len
    int 0x80
    jmp .exit

.invalid:
    mov eax, 4
    mov ebx, 1
    mov ecx, inv_msg
    mov edx, inv_msg_len
    int 0x80

.exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80
