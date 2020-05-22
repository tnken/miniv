module codegen
import parser

pub fn init() {
  println('.global main')
  println('main:')
}

pub fn end() {
  println('  pop %rax')
  println('  ret')
}

pub fn gen(node parser.Node) {
  if node.kind == .num {
    println('  push $$node.val')
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
