section .text
  jmp our_code_starts_here
f:
  push ebp
  mov ebp, esp
  sub esp, 0
  mov eax, [ebp + 2]
  add eax, 2
  mov esp, ebp
  pop ebp
  ret
our_code_starts_here:
  mov eax, 0
  mov esp, 128
  mov ebp, 128
  push ebp
  mov ebp, esp
  sub esp, 0
  push 2
  call f
  add esp, 1
  mov esp, ebp
  pop ebp
  jmp end_of_program
err_arith_not_num:
  push 1
err_comp_not_num:
  push 0
err_overflow:
  push 4
err_if_not_bool:
  push 3
err_logic_not_bool:
  push 2
end_of_program:
