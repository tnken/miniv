module codegen
import parser

pub fn ini() {
  println('.global main')
  println('main:')
  println('  push %rbp')
  println('  mov %rsp, %rbp')
  println('  sub $208, %rsp')
}

pub fn end() {
  println('  mov %rbp, %rsp')
  println('  pop %rbp')
  println('  ret')
}

fn gen_lvar(node parser.Node) {
  println('  mov %rbp, %rax')
  println('  sub $$node.offset, %rax')
  println('  push %rax')
}

pub fn gen(node parser.Node) {
  if node.kind == .num {
    println('  push $$node.val')
    return
  } else if node.kind == .lvar {
    gen_lvar(node)
    println('  pop %rax')
    println('  mov (%rax), %rax')
    println('  push %rax')
    return
  } else if node.kind == .assign {
    gen_lvar(node.lhs)
    gen(node.rhs)
    println('  pop %rdi')
    println('  pop %rax')
    println('  mov %rdi, (%rax)')
    println('  push %rdi')
    return
  }

  gen(node.lhs)
  gen(node.rhs)

  println('  pop %rdi')
  println('  pop %rax')

  if node.kind == .add {
    println('  add %rdi, %rax')
  } else if node.kind == .sub {
    println('  sub %rdi, %rax')
  } else if node.kind == .mul {
    println('  imul %rdi, %rax')
  } else if node.kind == .div {
    println('  cqo')
    println('  idiv %rdi')
  } else if node.kind == .eq {
    println('  cmp %rdi, %rax')
    println('  sete %al')
    println('  movzb %al, %rax')
  } else if node.kind == .ne {
    println('  cmp %rdi, %rax')
    println('  setne %al')
    println('  movzb %al, %rax')
  } else if node.kind == .lt {
    println('  cmp %rdi, %rax')
    println('  setl %al')
    println('  movzb %al, %rax')
  } else if node.kind == .le {
    println('  cmp %rdi, %rax')
    println('  setle %al')
    println('  movzb %al, %rax')
  }

  println('  push %rax')
}
