jmp 171
subi esp, 1
sw esp, ebp, 0
mov ebp, esp
subi esp, 6
lw ebp, ecx, 2
mov eax, ecx
testi eax, 1
jnz 193
movi eax, 0
testi eax, 1
jnz 193
lw ebp, ecx, 2
mov eax, ecx
cmpi eax, 0
je 18
movi eax, 2147483647
jmp 19
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
jne 199
mov edx, ebp
subi edx, 1
lw edx, ecx, 0
mov eax, ecx
cmpi eax, 4294967295
jne 41
movi eax, 0
jmp 165
lw ebp, ecx, 2
mov eax, ecx
testi eax, 1
jnz 193
movi eax, 2
testi eax, 1
jnz 193
lw ebp, ecx, 2
mov eax, ecx
cmpi eax, 2
je 54
movi eax, 2147483647
jmp 55
movi eax, 4294967295
mov edx, ebp
subi edx, 2
lw edx, ebx, 0
mov ebx, eax
mov edx, ebp
subi edx, 2
sw edx, ebx, 0
mov edx, ebp
subi edx, 2
lw edx, ecx, 0
mov eax, ecx
andi eax, 2147483647
cmpi eax, 2147483647
jne 199
mov edx, ebp
subi edx, 2
lw edx, ecx, 0
mov eax, ecx
cmpi eax, 4294967295
jne 77
movi eax, 2
jmp 165
lw ebp, ecx, 2
mov eax, ecx
testi eax, 1
jnz 190
movi eax, 2
testi eax, 1
jnz 190
lw ebp, ecx, 2
mov eax, ecx
subi eax, 2
mov edx, ebp
subi edx, 3
lw edx, ebx, 0
mov ebx, eax
mov edx, ebp
subi edx, 3
sw edx, ebx, 0
mov edx, ebp
subi edx, 3
lw edx, ecx, 0
subi esp, 1
sw esp, ecx, 0
movi ebx, 103
subi esp, 1
sw esp, ebx, 0
jmp 1
addi esp, 1
mov edx, ebp
subi edx, 4
lw edx, ebx, 0
mov ebx, eax
mov edx, ebp
subi edx, 4
sw edx, ebx, 0
lw ebp, ecx, 2
mov eax, ecx
testi eax, 1
jnz 190
movi eax, 4
testi eax, 1
jnz 190
lw ebp, ecx, 2
mov eax, ecx
subi eax, 4
mov edx, ebp
subi edx, 5
lw edx, ebx, 0
mov ebx, eax
mov edx, ebp
subi edx, 5
sw edx, ebx, 0
mov edx, ebp
subi edx, 5
lw edx, ecx, 0
subi esp, 1
sw esp, ecx, 0
movi ebx, 137
subi esp, 1
sw esp, ebx, 0
jmp 1
addi esp, 1
mov edx, ebp
subi edx, 6
lw edx, ebx, 0
mov ebx, eax
mov edx, ebp
subi edx, 6
sw edx, ebx, 0
mov edx, ebp
subi edx, 4
lw edx, ecx, 0
mov eax, ecx
testi eax, 1
jnz 190
mov edx, ebp
subi edx, 6
lw edx, ecx, 0
mov eax, ecx
testi eax, 1
jnz 190
mov edx, ebp
subi edx, 4
lw edx, ecx, 0
mov eax, ecx
mov edx, ebp
subi edx, 6
lw edx, ecx, 0
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
movi ebx, 0
sw esp, ebx, 0
movi ebx, 185
subi esp, 1
sw esp, ebx, 0
jmp 1
addi esp, 1
mov esp, ebp
lw esp, ebp, 0
addi esp, 1
jmp 205
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
