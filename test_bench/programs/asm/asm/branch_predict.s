section .text
  jmp our_code_starts_here
f:
  add eax, 1
  add eax, 1
  add eax, 1
  add eax, 1
  add eax, 1
  jmp return
our_code_starts_here:
  mov eax, 0
return:
  cmp eax, 5
  jne f
end_of_program:
