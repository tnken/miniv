import parser
import token

fn to_string(node parser.Node) string {
  if node.kind == .num {
    return node.val.str()
  }
  if node.kind == .lvar {
    return node.str
  }

  l := to_string(node.lhs)
  r := to_string(node.rhs)

  return '$l $node.str $r'
}

fn display_result(idx int, ok bool) {
  if ok {
    println('[ok]: ${idx}')
  } else {
    println('[faile]: ${idx}')
  }
}

fn test_parser() {
  inputs := [
    '(1+1)*(2-1)'
    '1+1*2-1',
    '(1+1)*4-6',
    'a:=1',
    'b:=1+1 - 1',
    'c:=3 c'
  ]

  expecting := [
    '1 + 1 * 2 - 1'
    '1 + 1 * 2 - 1',
    '1 + 1 * 4 - 6',
    'a := 1',
    'b := 1 + 1 - 1',
    'c := 3 c'
  ]

  for i, input in inputs {
    tok := token.tokenize(input)
    p := parser.new_parser(tok)
    program := p.parse()
    mut out := to_string(program[0])
    for node in program[1..] {
      out += ' ' + to_string(node)
    }
    assert out == expecting[i]
    display_result(i, out == expecting[i])
  }
}
