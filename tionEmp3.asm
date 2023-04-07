; Erik Lance L. Tiongquico - S14
global main
extern printf, system, scanf

section .data
clrstr db "cls",0
promptstart db "The signal has %d samples. ",10,0
prompt db "Enter coefficient h%d:",0
promptend db "Filter output:",0
promptagain db "Want to try again? (y/n): ",0

scanfmtD db "%d",0

signal dd -1, 3, 4, 0, 9, 0x80000000
sample_count dd 0

hnum dd 0
h0 dd 0
h1 dd 0
h2 dd 0



section .text
main:
    ;cls
    push clrstr
    call system
    add  esp, 4

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
    
    xor ECX, ECX
    mov [hnum], ECX
    
    ; --- User inputs 1
    push dword [hnum]
    push prompt
    call printf
    add esp, 8
    
    push h0
    push scanfmtD
    call scanf
    add esp, 8
    
    ; --- User inputs 2
    inc ECX
    mov [hnum], ECX
    
    push dword [hnum]
    push prompt
    call printf
    add esp, 8
    
    push h1
    push scanfmtD
    call scanf
    add esp, 8
    
    ; --- User inputs 3
    inc ECX
    mov [hnum], ECX
    
    push dword [hnum]
    push prompt
    call printf
    add esp, 8
    
    push h2
    push scanfmtD
    call scanf
    add esp, 8


operate:

print_output:
    
    
    xor eax, eax
    ret