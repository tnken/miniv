module parser

import token

fn seq(node Node) string {
	match node {
		NumNode {
			return it.val.str()
		}
		LvarNode {
			if it.is_arg {
				return '$it.str ${type_str(it.lvar.typ)}'
			} else {
				return it.str
			}
		}
		ReturnNode {
			return 'return ${seq(it.rhs)}'
		}
		AssignNode {
			l := seq(it.lhs)
			r := seq(it.rhs)
			return '$l := $r'
		}
		DeclareNode {
			l := seq(it.lhs)
			r := seq(it.rhs)
			return '$l = $r'
		}
		InfixNode {
			l := seq(it.lhs)
			r := seq(it.rhs)
			return '$l $it.str $r'
		}
		IfNode {
			cd := seq(it.condition)
			cs := seq(it.consequence)
			if it.has_alternative {
				alt := seq(it.alternative)
				return 'if $cd $cs else $alt'
			}
			return 'if $cd $cs'
		}
		ForNode {
			if it.is_cstyle {
				ini := seq(it.init)
				cd := seq(it.condition)
				inc := seq(it.increment)
				cs := seq(it.consequence)
				return 'for $ini ; $cd ; $inc $cs'
			}
			cd := seq(it.condition)
			cs := seq(it.consequence)
			return 'for $cd $cs'
		}
		BlockNode {
			if it.stmts.len > 0 {
				mut str := '{ '
				for stmt in it.stmts[..(it.stmts.len - 1)] {
					str += seq(stmt) + ' '
				}
				str += seq(it.stmts[it.stmts.len - 1])
				return str + ' }'
			}
			return '{ }'
		}
		FuncNode {
			block := seq(it.block)
			// TODO: fix more briefly
			if it.has_return {
				if it.args.len > 0 {
					arg := seq(it.args[0])
					return 'fn $it.name ( $arg ) ${type_str(it.return_type)} $block'
				} else {
					return 'fn $it.name ( ) ${type_str(it.return_type)} $block'
				}
			} else {
				if it.args.len > 0 {
					arg := seq(it.args[0])
					return 'fn $it.name ( $arg ) $block'
				} else {
					return 'fn $it.name ( ) $block'
				}
			}
		}
		FuncCallNode {
			return '$it.ident ( )'
		}
		ArrayNode {
			match it.ele_typ {
				.typ_int {
					mut s := '[ '
					for i, ele in it.elements {
						if i > 0 { s += ' , ' }
						s += seq(ele)
					}
					s += ' ]'
				} else {}
			}
		}
		StringNode {
			return '\' $it.text \''
		}
	}
}

fn exec_test(inputs []string, expecting []string) {
	for i, input in inputs {
		tok := token.tokenize(input)
		p := parse(tok)
		mut out := seq(p.program[0])
		for node in p.program[1..] {
			out += ' ' + seq(node)
		}
		assert out == expecting[i]
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
	exec_test(inputs, expecting)
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
	exec_test(inputs, expecting)
}

fn test_func_parsing() {
	inputs := [
		'fn func0() {}',
		'fn func1(a int) { b:=a }',
		'fn func2() int {return 1}',
		'fn func3(x int) int {return x+3}',
	]
	expecting := [
		'fn func0 ( ) { }',
		'fn func1 ( a int ) { b := a }',
		'fn func2 ( ) int { return 1 }',
		'fn func3 ( x int ) int { return x + 3 }',
	]
	exec_test(inputs, expecting)
}

fn test_array_parsing() {
	inputs := [
		'a := [1,2,3]',
		'b := [1+3-2,2,3]',
	]
	expecting := [
		'a := [ 1 , 2 , 3 ]',
		'b := [ 1 + 3 - 2 , 2 , 3 ]'
	]
	exec_test(inputs, expecting)
}

fn test_strign_parsing() {
	inputs := [
		'a := \'hello\''
	]
	expecting := [
		'a := \' hello \''
	]
	exec_test(inputs, expecting)
}
