module parser

import token

enum NodeKind {
	add
	sub
	mul
	div
	num
}

struct Node {
	pub mut:
	kind NodeKind
	val int
	lhs &Node
	rhs &Node
}

pub struct Parser {
	pub mut:
	token token.Token
}

pub fn new_parser(tk token.Token) &Parser {
	return &Parser{tk}
}

pub fn (p &Parser) parse() &Node {
  return p.expr()
}

fn new_node(kind NodeKind, lhs &Node, rhs &Node) &Node {
	return &Node{kind, 0, lhs, rhs}
}

fn new_node_num(val int) &Node {
	return &Node{.num, val, 0, 0}
}

fn (p &Parser) expr() &Node {
	node := p.mul()

	for {
		if p.token.consume('+') {
			node = new_node(.add, node, p.mul())
		} else if p.token.consume('-') {
			node = new_node(.sub, node, p.mul())
		} else {
			return node
		}
	}
}

fn (p &Parser) mul() &Node {
	node := p.unary()

	for {
		if p.token.consume('*') {
			node = new_node(.mul, node, p.unary())
		} else if p.token.consume('/'){
			node = new_node(.div, node, p.unary())
		} else {
			return node
		}
	}
}

fn (p &Parser) unary() &Node {
	if p.token.consume('+'){
		return p.primary()
	} else if p.token.consume('-'){
		return new_node(.sub, new_node_num(0), p.primary())
	}
	return p.primary()
}

fn (p &Parser) primary() &Node {
	if p.token.consume('(') {
		node := p.expr()
		p.token.expect(')')
		return node
	}
	return new_node_num(p.token.expect_number())
}
