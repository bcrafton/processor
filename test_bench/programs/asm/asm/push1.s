section .text
  jmp our_code_starts_here
our_code_starts_here:
  mov esp, 128
  mov ebp, 128
  sub esp, 1
  mov [ebp - 1], 100
  mov eax, [ebp - 1]
  
