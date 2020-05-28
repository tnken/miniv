module codegen
import parser

fn ini() {
  println('.global main')
  println('main:')
  println('  push %rbp')
  println('  mov %rsp, %rbp')
  println('  sub $208, %rsp')
}

fn end() {
  println('  mov %rbp, %rsp')
  println('  pop %rbp')
  println('  ret')
}

pub fn gen_program(p &parser.Parser) {
  ini()
  cg := Cgen{p}
  for node in p.program {
    cg.gen(node)
    println('  pop %rax')
  }
  end()
}

struct Cgen {
  p parser.Parser
}

fn (cg Cgen) gen_lvar(node parser.Node) {
  if node.kind != .lvar {
    panic('Error: Not local variable')
  }
  println('  mov %rbp, %rax')
  offset := cg.p.find_lvar(node.str).offset
  println('  sub $$offset, %rax')
  println('  push %rax')
}

fn (cg Cgen) gen(node parser.Node) {
  match node.kind {
    .num {
      println('  push $$node.val')
      return
    }
    .lvar {
      cg.gen_lvar(node)
      println('  pop %rax')
      println('  mov (%rax), %rax')
      println('  push %rax')
      return
    }
    .assign {
      cg.gen_lvar(node.lhs)
      cg.gen(node.rhs)
      println('  pop %rdi')
      println('  pop %rax')
      println('  mov %rdi, (%rax)')
      println('  push %rdi')
      return
    }
    .nd_return {
      cg.gen(node.rhs)
      println('  pop %rax')
      end()
      return
    } else {}
  }

  cg.gen(node.lhs)
  cg.gen(node.rhs)

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
