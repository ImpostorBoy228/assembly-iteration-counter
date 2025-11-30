# Realtime CPU Iteration Counter (x86_64 Linux)

This is a **low-level real-time iteration counter** implemented in **x86_64 assembly** for Linux. It measures how many iterations a tight loop can perform in a given time interval (roughly 1 second), using `clock_gettime` with `CLOCK_MONOTONIC`.

---

## Features

- Pure assembly (`nasm`) implementation.
- Works on Linux x86_64.
- Prints iteration count every ~1 second.
- Minimalistic, low-level, super fast.
- No dependencies except Linux syscalls.

---

## Requirements

- Linux x86_64
- `nasm` assembler
- `ld` linker

---

## Build

```bash
nasm -felf64 raw.asm -o raw.o
ld raw.o -o raw
```

---

## Run

```bash
./raw
```

Output will be something like:

```
4079550464
4005363712
4050780160
```

Each number represents the iterations completed in roughly 1 second.

---

## How it works

1. Use `clock_gettime(CLOCK_MONOTONIC)` to get the start time.
2. Run a tight loop incrementing a counter (`rbx`) until ~1 second has passed.
3. Calculate elapsed time using seconds + nanoseconds delta.
4. Convert the iteration count to ASCII and print using `write` syscall.
5. Reset timer and repeat.

---

## Syscalls Used

- `SYS_write` (1) – print iteration count to stdout.
- `SYS_clockgettime` (228) – read high-resolution monotonic time.
- `SYS_exit` (60) – exit the program.

---

## Notes

- Written in NASM syntax for ELF64.
- Iteration counter is stored in `rbx`.
- Timing is done with `CLOCK_MONOTONIC` for accuracy.
- No libc or external libraries are used.

---

## License

MIT License – feel free to fork and tweak for your projects.
