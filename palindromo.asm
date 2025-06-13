section .data
    ; Mensaje que se muestra al usuario para solicitar un número de hasta 10 dígitos
    prompt      db "Ingresa numero (max 10 dig): ", 0
    prompt_len  equ $ - prompt  ; Longitud del mensaje

    ; Mensaje que se mostrará si la entrada es inválida
    inv_msg     db "Entrada invalida.",10,0
    inv_msg_len equ $ - inv_msg

    ; Mensaje si el número ingresado es un palíndromo
    yes_msg     db "Es palindromo.",10,0
    yes_msg_len equ $ - yes_msg

    ; Mensaje si el número ingresado no es un palíndromo
    no_msg      db "No es palindromo.",10,0
    no_msg_len  equ $ - no_msg

section .bss
    ; Reservamos espacio para la entrada del usuario (32 bytes para asegurarnos de detectar entradas demasiado largas)
    buf     resb 32

    ; Aquí guardamos la longitud real de la cadena ingresada
    len     resb 1

section .text
global _start

%macro PRINT 2
    mov eax, 4
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

_start:
    ; Mostrar el mensaje de entrada al usuario
    PRINT prompt, prompt_len

    ; Leer la entrada del usuario
    mov eax, 3          ; syscall: sys_read
    mov ebx, 0          ; descriptor de entrada estándar (stdin)
    mov ecx, buf        ; puntero al buffer donde se almacenará la entrada
    mov edx, 32         ; número máximo de bytes a leer (más de 10 para poder detectar exceso)
    int 0x80
    mov [len], eax      ; guardamos la cantidad de bytes leídos (incluye '\n' si lo hay)

    ; Intentamos remover el salto de línea final si existe
    mov ecx, eax        ; guardamos longitud original
    dec ecx             ; posición del último carácter
    cmp byte [buf + ecx], 10 ; ¿es un salto de línea?
    jne .skip_trim           ; si no lo es, seguimos sin modificar
    mov byte [buf + ecx], 0  ; si lo es, lo reemplazamos por NULL
    mov [len], ecx           ; actualizamos la longitud (sin '\n')

.skip_trim:
    ; Verificamos si la longitud de la entrada es mayor a 10
    movzx ecx, byte [len] ; ecx ← longitud de entrada
    cmp ecx, 10
    ja .invalid           ; si hay más de 10 caracteres → entrada inválida

    ; Verificamos que todos los caracteres ingresados sean dígitos del 0 al 9
    xor esi, esi          ; índice desde 0
.check_digit:
    cmp esi, ecx
    jge .check_pal        ; si ya revisamos todos, pasamos a verificar si es palíndromo
    mov al, [buf + esi]   ; al ← carácter actual
    cmp al, '0'
    jl .invalid           ; si es menor que '0', no es un dígito
    cmp al, '9'
    jg .invalid           ; si es mayor que '9', tampoco es un dígito
    inc esi
    jmp .check_digit      ; continuamos con el siguiente carácter

.check_pal:
    ; Revisamos si el número es un palíndromo (se lee igual de izq. a der. que de der. a izq.)
    xor esi, esi          ; índice inicial (inicio de la cadena)
    mov edi, ecx
    dec edi               ; índice final (último carácter)
.pal_loop:
    cmp esi, edi
    jge .pal_true         ; si ya nos cruzamos en el centro → es palíndromo
    mov al, [buf + esi]
    mov bl, [buf + edi]
    cmp al, bl
    jne .pal_false        ; si no son iguales → no es palíndromo
    inc esi
    dec edi
    jmp .pal_loop         ; seguimos comparando hacia el centro

.pal_true:
    ; Mostramos mensaje de que sí es palíndromo
    PRINT yes_msg, yes_msg_len
    jmp .exit

.pal_false:
    ; Mostramos mensaje de que no es palíndromo
    PRINT no_msg, no_msg_len
    jmp .exit

.invalid:
    ; Mostramos mensaje de entrada inválida (más de 10 dígitos o caracteres no numéricos)
    PRINT inv_msg, inv_msg_len

.exit:
    ; Terminamos el programa limpiamente
    mov eax, 1      ; syscall: sys_exit
    xor ebx, ebx    ; código de salida 0
    int 0x80
