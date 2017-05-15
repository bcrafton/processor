jmp 23
subi esp, 1
sw esp, ebp, 0
mov ebp, esp
subi esp, 0
lw ebp, ecx, 2
mov eax, ecx
testi eax, 1
jnz 45
lw ebp, ecx, 3
mov eax, ecx
testi eax, 1
jnz 45
lw ebp, ecx, 2
mov eax, ecx
lw ebp, ecx, 3
add eax, ecx
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
movi ebx, 2
sw esp, ebx, 0
subi esp, 1
movi ebx, 4
sw esp, ebx, 0
movi ebx, 40
subi esp, 1
sw esp, ebx, 0
jmp 1
addi esp, 2
mov esp, ebp
lw esp, ebp, 0
addi esp, 1
jmp 60
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
