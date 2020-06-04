module parser

type Node = AssignNode | BlockNode | DeclareNode | ForNode | IfNode | InfixNode | LvarNode |
	NumNode | ReturnNode | FuncNode | FuncCallNode

enum InfixKind {
	add
	sub
	mul
	div
	lt
	le
	eq
	ne
}

struct InfixNode {
pub mut:
	kind InfixKind
	str  string
	lhs  Node
	rhs  Node
}

fn new_infix_node(kind InfixKind, str string, lhs, rhs Node) Node {
	return InfixNode{kind, str, lhs, rhs}
}

struct NumNode {
pub mut:
	val int
}

fn new_num_node(val int) Node {
	return NumNode{val}
}

struct LvarNode {
pub mut:
	str    string
	offset int
}

fn new_lvar_node(str string, offset int) Node {
	return LvarNode{str, offset}
}

struct AssignNode {
pub:
	lhs Node
	rhs Node
}

fn new_assign_node(lhs, rhs Node) Node {
	return AssignNode{lhs, rhs}
}

struct DeclareNode {
pub:
	lhs Node
	rhs Node
}

fn new_declare_node(lhs, rhs Node) Node {
	return DeclareNode{lhs, rhs}
}

struct ReturnNode {
pub:
	rhs Node
}

fn new_return_node(rhs Node) Node {
	return ReturnNode{rhs}
}

// if <condition> <consequence> else <alternative>
struct IfNode {
pub:
	condition       Node
	consequence     Node
	alternative     Node
	has_alternative bool
}

fn new_if_node(cdt, cse Node) IfNode {
	return IfNode{
		condition: cdt
		consequence: cse
		has_alternative: false
	}
}

fn new_if_eles_node(cdt, cse, alt Node) IfNode {
	return IfNode{
		condition: cdt
		consequence: cse
		alternative: alt
		has_alternative: true
	}
}

struct ForNode {
pub:
	init        Node
	condition   Node
	increment   Node
	consequence Node
	is_cstyle   bool
}

fn new_for_node(cond, cons Node) ForNode {
	return ForNode{
		condition: cond
		consequence: cons
		is_cstyle: false
	}
}

fn new_cstyle_for_node(init, cond, inc, cons Node) ForNode {
	return ForNode{
		init: init
		condition: cond
		increment: inc
		consequence: cons
		is_cstyle: true
	}
}

struct BlockNode {
pub:
	stmts []Node
}

fn new_block_node(stmts []Node) BlockNode {
	return BlockNode{
		stmts: stmts
	}
}

struct FuncNode {
pub mut:
	name string
	args []Node
	block Node
}

fn new_func_node(name string, block Node) FuncNode {
	return FuncNode {
		name: name
		block: block
	}
}

struct FuncCallNode {
pub mut:
	ident string
	args []Node
}

fn new_func_call_node(ident string) FuncCallNode {
	return FuncCallNode {
		ident: ident
	}
}
