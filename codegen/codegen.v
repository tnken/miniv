module codegen
import parser

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
  }

  println('  push %rax')
}
