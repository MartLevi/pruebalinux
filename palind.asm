; --- MACRO para imprimir mensajes por pantalla ---
%macro print_msg 2
    mov eax, 4
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

section .data
    ; Mensaje que se muestra al usuario para solicitarun numero de hasta 10 digitos
    prompt      db "Ingresa numero (max 10 dig): ", 0
    prompt_len  equ $ - prompt

    ; Mensaje que se mostrará si la entrada es inválida
    inv_msg     db "Entrada invalida.",10,0
    inv_msg_len equ $ - inv_msg

    ; Mensaje si el número ingresado es un palíndromo
    yes_msg     db "Es palindromo.",10,0
    yes_msg_len equ $ - yes_msg

    ; Mensaje si el número ingresado no es un palíndromo
    no_msg      db "No es palindromo.",10,0
    no_msg_len  equ $ - no_msg

    ; Mensaje que muestra si desea continuar o finalizar el programa 
    ask_again   db "Deseas continuar? (S/N): ", 0
    ask_again_len equ $ - ask_again

section .bss
 ; Reservamos espacio para la entrada del usuario (32 bytes para asegurarnos de detectar entradas demasiado largas)
    buf     resb 32 ; buffer para almacenar la entrada del usuario
    len     resb 1  ; longitud real de la entrada
    again   resb 2   ; para leer 'S' o 'N' al final

section .text
global _start

_start:
; Mostrar el mensaje de entrada al usuario
main_loop:
    print_msg prompt, prompt_len
    ; Leer entrada del usuario
    mov eax, 3       ; syscall: sys_read
    mov ebx, 0       ; descriptor de entrada (stdin)
    mov ecx, buf     ; buffer de destino
    mov edx, 32      ; máximo 32 caracteres
    int 0x80
    mov [len], eax   ; guardar cantidad de caracteres leídos

    ; Eliminar salto de línea
    mov ecx, eax
    dec ecx
    cmp byte [buf + ecx], 10
    jne .skip_trim
    mov byte [buf + ecx], 0     ; reemplazar '\n' por NULL
    mov [len], ecx
.skip_trim:

     ; Verificar que no exceda 10 caracteres
    movzx ecx, byte [len]
    cmp ecx, 10
    ja invalid      ; si es mayor, entrada inválida

     ; Verificar que cada carácter sea un número (0-9)
    xor esi, esi     ; índice inicial
.check_digit:
    cmp esi, ecx
    jge check_pal    ; si ya recorrimos todos, ir a verificación de palíndromo
    mov al, [buf + esi]
    cmp al, '0'
    jl invalid       ; menor que '0' no es dígito
    cmp al, '9'
    jg invalid       ; mayor que '9' no es dígito
    inc esi
    jmp .check_digit

        ; --- Verificación de palíndromo ---

check_pal:
    xor esi, esi         ; índice izquierdo (inicio)
    mov edi, ecx
    dec edi              ; índice derecho (final)
.pal_loop:
    cmp esi, edi
    jge pal_true          ; si ya nos cruzamos en el centro → es palíndromo
    mov al, [buf + esi]
    mov bl, [buf + edi]
    cmp al, bl
    jne pal_false          ; si no son iguales no es palindromo 
    inc esi
    dec edi
    jmp .pal_loop           ; seguimos comparando hacia el centro


    ; Mostramos mensaje de que sí es palíndromo
pal_true:
    print_msg yes_msg, yes_msg_len
    jmp ask_continue

    ; Mostramos mensaje de que no es palíndromo
pal_false:
    print_msg no_msg, no_msg_len
    jmp ask_continue

    ; Mostramos mensaje de entrada inválida (más de 10 dígitos o caracteres no numéricos)
invalid:
    print_msg inv_msg, inv_msg_len

    ; Preguntar si se desea continuar 
ask_continue:
    print_msg ask_again, ask_again_len

    ; Leer respuesta (S/N)
    mov eax, 3
    mov ebx, 0
    mov ecx, again
    mov edx, 2
    int 0x80

    ; Si escribe 'S' o 's', repetir
    mov al, [again]
    cmp al, 'S'
    je main_loop
    cmp al, 's'
    je main_loop

.exit:
    ; Salir del programa
    mov eax, 1
    xor ebx, ebx
    int 0x80

