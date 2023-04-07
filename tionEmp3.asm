; Erik Lance L. Tiongquico - S14
global main
extern printf

section .data
promptstart db "The signal has %d samples. ",0
prompt db "Enter coefficient h%d:",0
promptend db "Filter output:",0
promptagain db "Want to try again? (y/n): ",0

signal dd -1, 3, 4, 0, 9, 0x80000000

sample_count dd 0

section .text
main:
    mov ebp, esp; for correct debugging
    xor EAX, EAX    ; accumulator
    xor EBX, EBX    ; pointer for data
    xor ECX, ECX    ; counter
    
    add EBX, -4
    dec ECX
count_samples:
    inc ECX ; Starts from -1 to skip 0x80000000
    add EBX, 4
    mov EAX, [signal+EBX]   ; Get data from signal
    cmp EAX, 0x80000000
    
    jne count_samples
    
    mov [sample_count], ECX

begin:
    ; printf(promptstart)
    push dword [sample_count]
    push promptstart
    call printf
    add esp, 8  ; 2 bytes pushed
    
    
    
    
    
    
    xor eax, eax
    ret