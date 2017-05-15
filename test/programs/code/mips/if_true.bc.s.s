jmp 1
movi eax, 0
movi esp, 128
movi ebp, 128
subi esp, 1
sw esp, ebp, 0
mov ebp, esp
subi esp, 0
movi eax, 4294967295
andi eax, 2147483647
cmpi eax, 2147483647
jne 31
movi eax, 4294967295
cmpi eax, 4294967295
jne 17
movi eax, 20
jmp 18
movi eax, 10
mov esp, ebp
lw esp, ebp, 0
addi esp, 1
jmp 37
subi esp, 1
movi ebx, 1
sw esp, ebx, 0
subi esp, 1
movi ebx, 0
sw esp, ebx, 0
subi esp, 1
movi ebx, 4
sw esp, ebx, 0
subi esp, 1
movi ebx, 3
sw esp, ebx, 0
subi esp, 1
movi ebx, 2
sw esp, ebx, 0
