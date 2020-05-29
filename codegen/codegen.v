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
  match node {
   parser.LvarNode {
      println('  mov %rbp, %rax')
      offset := cg.p.get_lvar_offset(it.str)
      println('  sub $$offset, %rax')
      println('  push %rax')

    }  else {
      panic('Error: not local variable')
    }
  }
}

fn (cg Cgen) gen(node parser.Node) {
  match node {
    parser.NumNode { 
      println('  push $$it.val')
      return
    }
    parser.LvarNode { 
      cg.gen_lvar(node)
      println('  pop %rax')
      println('  mov (%rax), %rax')
      println('  push %rax')
      return
    }
    parser.ReturnNode { 
      cg.gen(it.rhs)
      println('  pop %rax')
      end()
      return
    }
    parser.AssignNode {
      cg.gen_lvar(it.lhs)
      cg.gen(it.rhs)
      println('  pop %rdi')
      println('  pop %rax')
      println('  mov %rdi, (%rax)')
      println('  push %rdi')
      return
    }
    parser.InfixNode {
      cg.gen(it.lhs)
      cg.gen(it.rhs)

      println('  pop %rdi')
      println('  pop %rax')

      match it.kind {
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
  }  
}
