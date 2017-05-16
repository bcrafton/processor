section .text
  jmp our_code_starts_here
our_code_starts_here:
  mov esp, 128
  mov ebp, 128
  push 100
  pop eax
