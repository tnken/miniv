import parser
import token

fn to_string(node parser.Node) string {
  match node.kind {
    .num { return node.val.str() }
    .lvar { return node.str }
    .nd_return{
      r := to_string(node.rhs)
      return '$node.str $r'
    } else {}
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
    'c:=3 c',
    'hoge := 3 hoge',
    'hoge:=1fuga:=2hoge+fuga',
    'return 3',
    'hoge := 3 return hoge'
  ]

  expecting := [
    '1 + 1 * 2 - 1'
    '1 + 1 * 2 - 1',
    '1 + 1 * 4 - 6',
    'a := 1',
    'b := 1 + 1 - 1',
    'c := 3 c',
    'hoge := 3 hoge',
    'hoge := 1 fuga := 2 hoge + fuga',
    'return 3',
    'hoge := 3 return hoge'
  ]

  for i, input in inputs {
    tok := token.tokenize(input)
    p := parser.new_parser(tok)
    p.parse()
    mut out := to_string(p.program[0])
    for node in p.program[1..] {
      out += ' ' + to_string(node)
    }
    assert out == expecting[i]
    display_result(i, out == expecting[i])
  }
}
