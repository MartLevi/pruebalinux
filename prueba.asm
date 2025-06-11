.model small
.stack 100h
.data
    msgPrompt db "Ingrese un numero (max 10 digitos): $"
    msgInvalido db 13,10, "Entrada invalida. Solo se permiten digitos.", 13,10,"$"
    msgSi db 13,10, "Es un palindromo.", 13,10,"$"
    msgNo db 13,10, "No es un palindromo.", 13,10,"$"
    buffer db 11 dup('$') ; almacena hasta 10 dígitos + terminador
    len db 0 ; longitud de la entrada

.code
start:
    mov ax, @data
    mov ds, ax

    ; Mostrar mensaje de entrada
    lea dx, msgPrompt
    call mostrar

    ; Leer cadena del usuario
    call leerCadena

    ; Validar solo dígitos
    call validarEntrada
    cmp al, 0
    je entradaInvalida

    ; Validar palíndromo
    call esPalindromo
    cmp al, 1
    je es_palindromo

    ; Mostrar "No es palindromo"
    lea dx, msgNo
    call mostrar
    jmp fin

es_palindromo:
    lea dx, msgSi
    call mostrar
    jmp fin

entradaInvalida:
    lea dx, msgInvalido
    call mostrar

fin:
    mov ah, 4ch
    int 21h

; ----------------------------
; Macros
; ----------------------------
mostrar macro
    mov ah, 09h
    int 21h
endm

; ----------------------------
; Procedimientos
; ----------------------------

leerCadena proc
    xor cx, cx
    mov si, 0
leer_loop:
    mov ah, 01h
    int 21h
    cmp al, 13         ; Enter?
    je fin_lectura
    cmp si, 10
    jae fin_lectura
    mov buffer[si], al
    inc si
    jmp leer_loop
fin_lectura:
    mov len, si
    ret
leerCadena endp

validarEntrada proc
    xor si, si
val_loop:
    mov al, buffer[si]
    cmp al, '0'
    jb invalido
    cmp al, '9'
    ja invalido
    inc si
    cmp si, len
    jl val_loop
    mov al, 1
    ret
invalido:
    mov al, 0
    ret
validarEntrada endp

esPalindromo proc
    xor si, si
    mov cl, len
    dec cl
    mov di, cx
pal_loop:
    mov al, buffer[si]
    mov bl, buffer[di]
    cmp al, bl
    jne no_pal
    inc si
    dec di
    cmp si, di
    jge si_es
    jmp pal_loop
si_es:
    mov al, 1
    ret
no_pal:
    mov al, 0
    ret
esPalindromo endp

end start
