module parser

import token

struct Parser {
pub mut:
	token     token.Token
	program   []Node
	table Table
}

pub fn parse(tk token.Token) &Parser {
	p := &Parser{
		token: tk
		table: &Table{}
	}
	p.program = p.program()
	return p
}

fn (p &Parser) program() []Node {
	mut stmts := []Node{}
	for p.token.kind != .eof {
		stmts << p.stmt()
	}
	return stmts
}

fn (p &Parser) stmt() Node {
	if p.token.consume('fn') {
		name := p.token.expect_ident()
		p.token.expect('(')
		mut args := []Node{}
		if !p.token.consume(')') {
			for {
				lvar := p.primary()
				match lvar {
					LvarNode {
						tp := p.token.expect_primitive_type()
						it.typ = new_type(tp)
						it.is_arg = true
						args << lvar
					} else {}
				}
				if p.token.consume(')') { break }
				p.token.expect(',')
			}
		}
		mut has_return := false
		mut typ := Type{}
		if p.token.str != '{' {
			tp := p.token.expect_primitive_type()
			typ = new_type(tp)
			has_return = true
		}
		block := p.stmt()
		mut fnode := new_func_node(name, block)
		fnode.has_return = has_return
		if has_return {
			fnode.return_type = typ
		}
		fnode.args = args
		return fnode
	}
	if p.token.consume('return') {
		return new_return_node(p.equality())
	}
	if p.token.consume('if') {
		exp := p.expr()
		con := p.stmt()
		if p.token.consume('else') {
			alt := p.stmt()
			return new_if_eles_node(exp, con, alt)
		}
		return new_if_node(exp, con)
	}
	if p.token.consume('for') {
		exp := p.expr()
		if p.token.consume(';') {
			cond := p.expr()
			p.token.expect(';')
			inc := p.expr()
			cons := p.stmt()
			return new_cstyle_for_node(exp, cond, inc, cons)
		}
		cons := p.stmt()
		return new_for_node(exp, cons)
	}
	if p.token.consume('{') {
		mut stmts := []Node{}
		for !p.token.consume('}') {
			stmts << p.stmt()
		}
		return new_block_node(stmts)
	}
	node := p.expr()
	return node
}

fn (p &Parser) expr() Node {
	node := p.assign()
	return node
}

fn (p &Parser) assign() Node {
	mut node := p.equality()
	// TODO: divide roles of := and =
	if p.token.consume(':=') {
		node = new_assign_node(node, p.assign())
	} else if p.token.consume('=') {
		node = new_declare_node(node, p.assign())
	}
	return node
}

fn (p &Parser) equality() Node {
	mut node := p.relational()
	for {
		if p.token.consume('==') {
			node = new_infix_node(.eq, '==', node, p.relational())
		} else if p.token.consume('!=') {
			node = new_infix_node(.ne, '!=', node, p.relational())
		} else {
			return node
		}
	}
}

fn (p &Parser) relational() Node {
	mut node := p.add()
	for {
		if p.token.consume('<') {
			node = new_infix_node(.lt, '<', node, p.add())
		} else if p.token.consume('>') {
			node = new_infix_node(.lt, '>', p.add(), node)
		} else if p.token.consume('<=') {
			node = new_infix_node(.le, '<=', node, p.add())
		} else if p.token.consume('>=') {
			node = new_infix_node(.le, '>=', p.add(), node)
		} else {
			return node
		}
	}
}

fn (p &Parser) add() Node {
	mut node := p.mul()
	for {
		if p.token.consume('+') {
			node = new_infix_node(.add, '+', node, p.mul())
		} else if p.token.consume('-') {
			node = new_infix_node(.sub, '-', node, p.mul())
		} else {
			return node
		}
	}
}

fn (p &Parser) mul() Node {
	mut node := p.unary()
	for {
		if p.token.consume('*') {
			node = new_infix_node(.mul, '*', node, p.unary())
		} else if p.token.consume('/') {
			node = new_infix_node(.div, '/', node, p.unary())
		} else {
			return node
		}
	}
}

fn (p &Parser) unary() Node {
	if p.token.consume('+') {
		return p.primary()
	} else if p.token.consume('-') {
		return new_infix_node(.sub, '-', new_num_node(0), p.primary())
	}
	return p.primary()
}

fn (p &Parser) primary() Node {
	if p.token.consume('(') {
		node := p.expr()
		p.token.expect(')')
		return node
	}
	if p.token.kind == .ident {
		ident := p.token
		p.token.next_token()
		if p.token.consume('('){
			mut fnode := new_func_call_node(ident.str)
			for !p.token.consume(')'){
				fnode.args << p.equality()
			}
			return fnode
		} else {
			lvar := p.table.enter_lvar(ident.str)
			node := new_lvar_node(lvar.name, lvar.offset)
			return node
		}
	}
	return new_num_node(p.token.expect_number())
}
