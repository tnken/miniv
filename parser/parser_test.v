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
		'hoge := 3 return hoge',
		'if 3 1+1',
		'if 1+1-1 3+3',
		'if 0+1 return 2 else return 3'
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
		'hoge := 3 return hoge',
		'if 3 1 + 1',
		'if 1 + 1 - 1 3 + 3',
		'if 0 + 1 return 2 else return 3'
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

fn test_for_parsing() {
	inputs := [
		'a:=1 for a<10 a=a+1 a',
		'a:=0 for i:=0; i<10; i=i+1 a=a+1 a',
		'a:=1 for a<10 { a=a+1 a=a+1 } a'
	]
	expecting := [
		'a := 1 for a < 10 a = a + 1 a',
		'a := 0 for i := 0 ; i < 10 ; i = i + 1 a = a + 1 a',
		'a := 1 for a < 10 { a = a + 1 a = a + 1 } a'
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
