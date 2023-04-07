; Erik Lance L. Tiongquico - S14
global main
extern printf, system, scanf

section .data
clrstr db "cls",0
promptstart db "The signal has %d samples. ",10,0
prompt db "Enter coefficient h%d:",10,0
promptend db "Filter output:",10,0
promptagain db "Want to try again? (y/n): ",0

scanfmtD db "%d",0

signal dd -1, 3, 4, 0, 9, 0x80000000
sample_count dd 0
signal_end dd 0

h0 dd 0
h1 dd 0
h2 dd 0

print_filter dd 0
print_answer db "%d",0
print_comma db ", ",0

; Temporary
z1 dd 0
z2 dd 0

section .text
main:
    mov ebp, esp; for correct debugging
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
    mov [signal_end], EBX
    
    ; printf(promptstart)
    push dword [sample_count]
    push promptstart
    call printf
    add esp, 8  ; 2 bytes pushed
    
    ; --- User inputs 1
    xor EBX, EBX
    push EBX
    push prompt
    call printf
    add esp, 8
    
    push h0 ; Scan to h0
    push scanfmtD
    call scanf
    add esp, 8
    
    ; --- User inputs 2
    inc EBX
    
    push EBX
    push prompt
    call printf
    add esp, 8
    
    push h1 ; Scan to h1
    push scanfmtD
    call scanf
    add esp, 8
    
    ; --- User inputs 3
    inc EBX
    
    push EBX
    push prompt
    call printf
    add esp, 8
    
    push h2 ; Scan to h2
    push scanfmtD
    call scanf
    add esp, 8


operate:
    ; EBX contains pointer to last number
    mov EBX, [signal_end]
    add EBX, -4
    
    ; Store bottom pointer of the list
    xor EDX, EDX
    xor ESI, ESI    ; For counting loop

    push promptend
    call printf
    add esp, 4
    
    jmp filter

comma:
    ; If not yet last answer, add comma
    push print_comma
    call printf
    add esp, 4
    
filter:
    ; --- z1
    xor EAX, EAX
    add EAX, dword [h2]   
    
    mov ECX, dword [signal+EDX]   ; Get x0
    mul EAX
    
    mov [z1], ECX   ; x(n) * h2
    add EDX, 4
    
    ; --- z2
    xor EAX, EAX
    add EAX, dword [h1]
    
    mov ECX, [signal+EDX]   ; Get x1
    mul EAX
    
    mov dword [z2], ECX   ; x(n+1) * h1
    add EDX, 4
    
    ; --- FINAL
    xor EAX, EAX
    add EAX, [h0]
    
    mov ECX, [signal+EDX]   ; Get x2
    mul EAX
    
    add EAX, dword [z1]   ; [ x(n+0) * h2 ] +
    add EAX, dword [z2]   ; [ x(n+1) * h1 ] +  [x(n+2) * h0 ]
    
    
print_output:
    mov [print_filter], EAX
    
    ; Print answer
    push print_filter
    push print_answer
    call printf
    add esp, 8
    
    add ESI, 3  ; Add 1 for loop iteration, and 2 to make sure below last 2
    cmp ESI, [sample_count]  ; Check if reached last 2
    je tapos  ; Program is done!
    
    add ESI, -2     ; Normalize back to normal looping

    mov EDX, ESI    ; Start at index of loop
    imul EDX, 4     ; Pointer format
    jmp comma   ; Back to filtering (and add comma to number!)
    
tapos:
    xor eax, eax
    ret