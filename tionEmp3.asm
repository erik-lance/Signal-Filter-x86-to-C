; Erik Lance L. Tiongquico - S14
global main
extern printf, system, scanf, getchar

section .data
clrstr db "cls",0
promptstart db "The signal has %d samples. ",10,0
prompt db "Enter coefficient h%d:",10,0
promptend db "Filter output:",10,0
promptagain db 10,"Want to try again? (y/n): ",0

scanfmtD db "%d",0

signal dd -1, 3, 4, 0, 9, 0x80000000
sample_count dd 0
signal_start dd 0
signal_end dd 0
signal_ctr dd 0

h0 dd 0
h1 dd 0
h2 dd 0

print_answer db "%d",0
print_comma db ", ",0

; Temporary
z1 dd 0
z2 dd 0

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

    mov [signal_end], EBX
    
    ; printf(promptstart)
    push dword [sample_count]
    push promptstart
    call printf
    add esp, 8  ; 2 bytes pushed

begin:
    
    
    ; --- User inputs 1
    xor EBX, EBX
    push EBX
    push prompt
    call printf ; printf("Enter coefficient h%d: ", EBX);
    add esp, 8
    
    push h0 ; Scan to h0
    push scanfmtD
    call scanf  ; scanf("%d: ", h0);
    add esp, 8
    
    ; --- User inputs 2
    inc EBX
    
    push EBX
    push prompt
    call printf ; printf("Enter coefficient h%d: ", EBX);
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
    push promptend
    call printf
    add esp, 4
   
    
    xor EBX, EBX    
    mov [signal_start], EBX ; For pointer start
    mov [signal_ctr], EBX   ; For counting loop
    
    jmp filter

comma:
    ; If not yet last answer, add comma
    push print_comma
    call printf
    add esp, 4
    
filter:
    mov EBX, [signal_start]

    ; --- z1
    xor ECX, ECX
    add ECX, dword [h2]   
    
    mov EAX, dword [signal+EBX]   ; Get x0
    mul ECX
    
    mov [z1], EAX   ; x(n) * h2
    add EBX, 4
    
    ; --- z2
    xor ECX, ECX
    add ECX, dword [h1]
    
    mov EAX, dword [signal+EBX]   ; Get x1
    mul ECX
    
    mov [z2], EAX   ; x(n+1) * h1
    add EBX, 4
    
    ; --- FINAL
    xor ECX, ECX
    add ECX, dword [h0]
    
    mov EAX, dword [signal+EBX]   ; Get x2
    mul ECX
    
    add EAX, dword [z1]   ; [ x(n+0) * h2 ] +
    add EAX, dword [z2]   ; [ x(n+1) * h1 ] +  [x(n+2) * h0 ]
    
print_output:
    ; Print answer
    push EAX
    push print_answer   ; printf("%d");
    call printf
    add esp, 8
    
    mov EBX, [signal_ctr]
    add EBX, 3  ; Add 1 for loop iteration, and 2 to make sure below last 2
    cmp EBX, [sample_count]  ; Check if reached last 2
    je tapos  ; Program is done!
    
    add EBX, -2     ; Normalize back to normal looping
    mov [signal_ctr], EBX

    mov EBX, [signal_start]
    add EBX, 4
    mov [signal_start], EBX
    jmp comma   ; Back to filtering (and add comma to number!)
    
tapos:
    push promptagain
    call printf
    add esp, 4

    call getchar ; This automatically grabs EAX in C.
    call getchar ; This automatically grabs EAX in C.
    add esp, 8   ; This is simply for cheating the buffer.
    
    cmp EAX, 89 ; Check if (Y)
    je begin
    
    cmp EAX, 121 ; Check if (y)
    je begin

    xor eax, eax
    ret