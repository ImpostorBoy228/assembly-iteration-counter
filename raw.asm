BITS 64
GLOBAL _start

SECTION .data
ten:       dq 10
billion:   dq 1000000000
newline:   db 10

SECTION .bss
start:     resq 2     ; sec, nsec
now:       resq 2
buf:       resb 32

SECTION .text

%define SYS_write 1
%define SYS_clockgettime 228
%define SYS_exit 60
%define CLOCK_MONOTONIC 1

_start:
    ; get start timestamp
    mov rdi, CLOCK_MONOTONIC
    mov rsi, start
    mov rax, SYS_clockgettime
    syscall

    xor rbx, rbx        ; iteration counter

main_loop:
    inc rbx
    test rbx, 0xFFFF
    jnz main_loop

    ; now timestamp
    mov rdi, CLOCK_MONOTONIC
    mov rsi, now
    mov rax, SYS_clockgettime
    syscall

    ; r8 = sec delta
    mov r8, [now]
    sub r8, [start]

    ; r9 = nsec delta
    mov r9, [now+8]
    sub r9, [start+8]

    ; elapsed ns = r8 * 1e9 + r9
    mov rax, r8
    mov rcx, [billion]
    mul rcx
    add rax, r9

    cmp rax, [billion]
    jb main_loop

    ; convert rbx to ASCII
    ; pointer = buf + 31
    mov r10, buf
    add r10, 31

    ; write newline at end
    mov byte [r10], 10
    dec r10

    mov r11, rbx
    cmp r11, 0
    jne .digits

    mov byte [r10], '0'
    jmp .out_ready

.digits:
.convert:
    xor rdx, rdx
    mov rax, r11
    mov rcx, [ten]
    div rcx
    add dl, '0'
    mov [r10], dl
    dec r10
    mov r11, rax
    test r11, r11
    jnz .convert

.out_ready:
    inc r10                         ; point to first digit
    mov rdi, 1
    mov rsi, r10

    mov rdx, buf
    add rdx, 32
    sub rdx, r10                    ; length

    mov rax, SYS_write
    syscall

    ; reset timestamps
    mov rax, [now]
    mov [start], rax
    mov rax, [now+8]
    mov [start+8], rax

    xor rbx, rbx
    jmp main_loop
