import parser
import token

fn to_postfix(node parser.Node) string {
	if node.kind == .num {
		return node.val.str()
	}

	l := to_postfix(node.lhs)
	r := to_postfix(node.rhs)

	if node.kind == .add {
		return '$l $r +'
	} else if node.kind == .sub {
		return '$l $r -'
	} else if node.kind == .mul {
		return '$l $r *'
	} else if node.kind == .div {
		return '$l $r /'
	}
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
		'(1+1) * (2-1)'
		'1+1*2-1',
		'(1+1)*4-6'
	]

	expecting := [
		'1 1 + 2 1 - *',
		'1 1 2 * + 1 -',
		'1 1 + 4 * 6 -'
	]

	for i, input in inputs {
		tok := token.tokenize(input)
		p := parser.new_parser(tok)
		node := p.parse()
		r := to_postfix(node)
		assert r == expecting[i]
		display_result(i, r == expecting[i])
	}
}
