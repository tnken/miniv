import parser
import token

fn test_parser() {
  inputs := [
    '1+2',
    '(1+1)*(2-1)',
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
    '1 + 2',
    '1 + 1 * 2 - 1',
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
    mut out := parser.sequence(p.program[0])
    for node in p.program[1..] {
      out += ' ' + parser.sequence(node)
    }
    assert out == expecting[i]
  }
}
