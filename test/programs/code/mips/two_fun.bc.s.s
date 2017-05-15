jmp 69
subi esp, 1
sw esp, ebp, 0
mov ebp, esp
subi esp, 0
lw ebp, ecx, 2
subi esp, 1
sw esp, ecx, 0
subi esp, 1
movi ebx, 0
sw esp, ebx, 0
movi ebx, 15
subi esp, 1
sw esp, ebx, 0
jmp 22
addi esp, 2
mov esp, ebp
lw esp, ebp, 0
addi esp, 1
lw esp, ebx, 0
addi esp, 1
jr ebx
subi esp, 1
sw esp, ebp, 0
mov ebp, esp
subi esp, 1
lw ebp, ecx, 2
mov eax, ecx
testi eax, 1
jnz 91
movi eax, 20
testi eax, 1
jnz 91
lw ebp, ecx, 2
mov eax, ecx
cmpi eax, 20
je 39
movi eax, 2147483647
jmp 40
movi eax, 4294967295
mov edx, ebp
subi edx, 1
lw edx, ebx, 0
mov ebx, eax
mov edx, ebp
subi edx, 1
sw edx, ebx, 0
mov edx, ebp
subi edx, 1
lw edx, ecx, 0
mov eax, ecx
andi eax, 2147483647
cmpi eax, 2147483647
jne 97
mov edx, ebp
subi edx, 1
lw edx, ecx, 0
mov eax, ecx
cmpi eax, 4294967295
jne 62
movi eax, 60
jmp 63
movi eax, 0
mov esp, ebp
lw esp, ebp, 0
addi esp, 1
lw esp, ebx, 0
addi esp, 1
jr ebx
movi eax, 0
movi esp, 128
movi ebp, 128
subi esp, 1
sw esp, ebp, 0
mov ebp, esp
subi esp, 0
subi esp, 1
movi ebx, 20
sw esp, ebx, 0
movi ebx, 83
subi esp, 1
sw esp, ebx, 0
jmp 1
addi esp, 1
mov esp, ebp
lw esp, ebp, 0
addi esp, 1
jmp 103
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
