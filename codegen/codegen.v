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
  match node.kind {
    .num {
      println('  push $$node.val')
      return
    }
    .lvar {
      gen_lvar(node)
      println('  pop %rax')
      println('  mov (%rax), %rax')
      println('  push %rax')
      return
    }
    .assign {
      gen_lvar(node.lhs)
      gen(node.rhs)
      println('  pop %rdi')
      println('  pop %rax')
      println('  mov %rdi, (%rax)')
      println('  push %rdi')
      return
    } else {}
  }

  gen(node.lhs)
  gen(node.rhs)

  println('  pop %rdi')
  println('  pop %rax')

  match node.kind {
    .add {
      println('  add %rdi, %rax')
    }
    .sub {
      println('  sub %rdi, %rax')
    }
    .mul {
      println('  imul %rdi, %rax')
    }
    .div {
      println('  cqo')
      println('  idiv %rdi')
    }
    .eq {
      println('  cmp %rdi, %rax')
      println('  sete %al')
      println('  movzb %al, %rax')
    }
    .ne {
      println('  cmp %rdi, %rax')
      println('  setne %al')
      println('  movzb %al, %rax')
    }
    .lt {
      println('  cmp %rdi, %rax')
      println('  setl %al')
      println('  movzb %al, %rax')
    }
    .le {
      println('  cmp %rdi, %rax')
      println('  setle %al')
      println('  movzb %al, %rax')
    } else {}
  }

  println('  push %rax')
}
