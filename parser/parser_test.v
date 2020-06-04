module parser

import token

fn sequence(node Node) string {
	match node {
		NumNode {
			return it.val.str()
		}
		LvarNode {
			return it.str
		}
		ReturnNode {
			return 'return ${sequence(it.rhs)}'
		}
		AssignNode {
			l := sequence(it.lhs)
			r := sequence(it.rhs)
			return '$l := $r'
		}
		DeclareNode {
			l := sequence(it.lhs)
			r := sequence(it.rhs)
			return '$l = $r'
		}
		InfixNode {
			l := sequence(it.lhs)
			r := sequence(it.rhs)
			return '$l $it.str $r'
		}
		IfNode {
			cd := sequence(it.condition)
			cs := sequence(it.consequence)
			if it.has_alternative {
				alt := sequence(it.alternative)
				return 'if $cd $cs else $alt'
			}
			return 'if $cd $cs'
		}
		ForNode {
			if it.is_cstyle {
				ini := sequence(it.init)
				cd := sequence(it.condition)
				inc := sequence(it.increment)
				cs := sequence(it.consequence)
				return 'for $ini ; $cd ; $inc $cs'
			}
			cd := sequence(it.condition)
			cs := sequence(it.consequence)
			return 'for $cd $cs'
		}
		BlockNode {
			if it.stmts.len > 0 {
				mut str := '{ '
				for stmt in it.stmts[..(it.stmts.len - 1)] {
					str += sequence(stmt) + ' '
				}
				str += sequence(it.stmts[it.stmts.len - 1])
				return str + ' }'
			}
			return ''
		}
		FuncNode {
			block := sequence(it.block)
			arg := sequence(it.args[0])
			return 'fn $it.name ( $arg ) $block'
		}
		FuncCallNode {
			return '$it.ident ( ) '
		}
	}
}

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
		mut out := sequence(p.program[0])
		for node in p.program[1..] {
			out += ' ' + sequence(node)
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
		mut out := sequence(p.program[0])
		for node in p.program[1..] {
			out += ' ' + sequence(node)
		}
		assert out == expecting[i]
	}
}

fn test_func_parsing() {
	inputs := [
		'fn func1(x) {return 1}',
	]
	expecting := [
		'fn func1 ( x ) { return 1 }',
	]
	for i, input in inputs {
		tok := token.tokenize(input)
		p := parser.new_parser(tok)
		p.parse()
		mut out := sequence(p.program[0])
		for node in p.program[1..] {
			out += ' ' + sequence(node)
		}
		assert out == expecting[i]
	}
}
