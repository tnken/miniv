module parser

import token

struct Parser {
pub mut:
	token     token.Token
	program   []Node
	table &Table
}

pub fn parse(tk token.Token) &Parser {
	p := &Parser{
		token: tk
		table: &Table{latest_lvar: &Lvar{}}
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
		p.table = &Table{latest_lvar: &Lvar{}}
		name := p.token.expect_ident()
		p.token.expect('(')
		mut args := []Node{}
		if !p.token.consume(')') {
			for {
				node := p.primary()
				if node is LvarNode {
					mut lvar := lvar_node(node)
					tp := p.token.expect_type_name()
					lvar.is_arg = true
					lvar.lvar.typ = type_kind(tp)
					args << lvar
				}
				if p.token.consume(')') { break }
				p.token.expect(',')
			}
		}
		if p.token.str != '{' {
			tp := p.token.expect_type_name()
			block := p.stmt()
			mut node := new_func_node(name, block, true)
			node.return_type = type_kind(tp)
			node.args = args
			return node
		} else {
			block := p.stmt()
			mut node := new_func_node(name, block, false)
			node.args = args
			return node
		}
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
	if node is LvarNode {
		mut lvar := lvar_node(node)
		if p.token.consume(':=') {
			rhs := p.assign()
			if rhs is ArrayNode {
				lvar.lvar.len = rhs.length()
			}
			node = new_assign_node(node, rhs)
		} else if p.token.consume('=') {
			rhs := p.assign()
			lvar.lvar.typ = rhs.typ_kind()
			node = new_declare_node(node, rhs)
		}
		return node
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
	if p.token.consume('[') {
		mut elements := []Node{}
		if !p.token.consume(']') {
			for {
				ele := p.equality()
				elements << ele
				if p.token.consume(']') { break }
				p.token.expect(',')
			}
		}
		return new_array_node(elements)
	}
	if p.token.consume('\'') {
		node := new_string_node(p.token.str)
		p.token.expect_text()
		p.token.expect('\'')
		return node
	}
	if p.token.kind == .ident {
		ident := p.token
		p.token.next_token()
		if p.token.consume('('){
			mut node := new_func_call_node(ident.str)
			for !p.token.consume(')'){
				node.args << p.equality()
			}
			return node
		} else {
			if p.table.search_lvar(ident.str) {
				mut node := new_lvar_node(ident.str, &p.table.lvar[ident.str], false, Node{})
				if p.token.consume('[') {
					node = new_lvar_node(ident.str, &p.table.lvar[ident.str], true, p.equality())
					p.token.expect(']')
				}
				return node
			} else {
				// TODO: lvar handling is little complex, fix them more simply.
				lvar := p.table.enter_lvar(ident.str)
				node := new_lvar_node(ident.str, lvar, false, Node{})
				return node
			}
		}
	}
	return new_num_node(p.token.expect_number())
}
