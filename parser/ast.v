module parser

type Node = AssignNode | BlockNode | DeclareNode | ForNode | IfNode | InfixNode | LvarNode |
	NumNode | ReturnNode | FuncNode | FuncCallNode | ArrayNode | StringNode

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
	is_arg bool
	lvar &Lvar
	array_access bool
	access_offset Node
}

fn new_lvar_node(str string, lvar &Lvar, array_acc bool, acc_offset Node) Node {
	return LvarNode{str, false, lvar, array_acc, acc_offset}
}

pub fn lvar_node(n Node) LvarNode {
	match n {
		LvarNode {
			return it
		} else {}
	}
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
pub:
	name string
	block Node
	has_return bool
pub mut:
	args []Node
	return_type TypeKind
}

fn new_func_node(name string, block Node, has_return bool) FuncNode {
	return FuncNode {
		name: name
		block: block
		has_return: has_return
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

struct ArrayNode {
pub mut:
	ele_typ TypeKind
	len int
	elements []Node
}

fn new_array_node(ele []Node) ArrayNode {
	ele_typ := ele[0].typ_kind()
	for typ in ele {
		if ele_typ != typ.typ_kind() {
			panic('error: unexpected element type')
		}
	}
	return ArrayNode{ele_typ: ele_typ, len: ele.len, elements: ele}
}

fn (n Node) typ_kind() TypeKind {
	match n {
		InfixNode { return .typ_int }
		NumNode { return .typ_int }
		LvarNode { return it.lvar.typ }
		ArrayNode {return .typ_array }
		else {}
	}
}

fn (n Node) length() int {
	match n {
		ArrayNode{ return it.len }
		else { return 1 }
	}
}

struct StringNode {
	pub mut:
		text string
}

fn new_string_node(text string) Node {
	return StringNode{text}
}
