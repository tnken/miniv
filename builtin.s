# <-------------- buitin i/o --------------
builtin.string_length:
  xor %rax, %rax
.loop:
  cmpb $0, (%rdi, %rax, 1)
  je .end
  inc %rax
  jmp .loop
.end:
  ret

builtin.print_uint:
  mov %rdi, %rax
  mov %rsp, %rdi
  push $0
  sub $16, %rsp
  dec %rdi
  mov $10, %r8

.loop1:
  xor %rdx, %rdx
  div %r8
  or $0x30, %dl
  dec %rdi
  mov %dl, (%rdi)
  test %rax, %rax
  jnz .loop1
  call builtin.print_string
  add $24, %rsp
  ret

builtin.print_newline:
  mov $10, %rdi
  jmp builtin.print_char

builtin.print_char:
  push %rdi
  mov %rsp, %rdi
  call builtin.print_string
  pop %rdi
  ret

builtin.print_string:
  push %rdi
  call builtin.string_length
  pop %rsi
  mov %rax, %rdx
  mov $1, %rax
  mov $1, %rdi
  syscall
  ret
# -------------- buitin i/o -------------->
