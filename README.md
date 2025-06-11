```bash
nasm -f elf32 palindromo.asm -o palindromo.o
ld -m elf_i386 palindromo.o -o palindromo
./palindromo
```
