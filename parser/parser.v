module parser

import token

enum NodeKind {
  add        // +
  sub        // -
  mul        // *
  div        // /
  num        // number
  lt         // <
  le         // <=
  eq         // ==
  ne         // !=
  assign     // :=
  lvar       // hoge
  nd_return  // return
  nd_if
}

type Node = InfixNode | NumNode | LvarNode | AssignNode | ReturnNode |
            IfNode

struct InfixNode {
  pub mut:
  kind NodeKind
  str string
  lhs Node
  rhs Node
}

fn new_infix_node(kind NodeKind, str string, lhs Node, rhs Node) Node {
  return InfixNode{kind, str, lhs, rhs}
}

struct NumNode {
  pub mut:
  kind NodeKind
  val int
}

fn new_num_node(val int) Node {
  return NumNode{.num, val}
}

struct LvarNode {
  pub mut:
  kind NodeKind
  str string
  offset int
}

fn new_lvar_node(str string, offset int) Node {
  return LvarNode{.lvar, str, offset}
}

struct AssignNode {
  pub:
  kind NodeKind
  lhs Node
  rhs Node
}

fn new_assign_node(lhs Node, rhs Node) Node {
  return AssignNode{.assign, lhs, rhs}
}

struct ReturnNode {
  pub:
  kind NodeKind
  rhs Node
}

fn new_return_node(rhs Node) Node {
  return ReturnNode{.nd_return, rhs}
}

// if <condition> <consequence> else <alternative>
struct IfNode {
  pub:
  kind NodeKind
  condition Node
  consequence Node
  alternative Node
  has_alternative bool
}

fn new_if_node(cdt Node, cse Node) IfNode {
  return IfNode{
    kind: .nd_if
    condition: cdt
    consequence: cse
    has_alternative: false
  }
}

fn new_if_eles_node(cdt Node, cse Node, alt Node) IfNode {
  return IfNode{
    kind: .nd_if
    condition: cdt
    consequence: cse
    alternative: alt
    has_alternative: true
  }
}

pub fn sequence(node Node) string {
  match node {
    NumNode { return it.val.str() }
    LvarNode { return it.str }
    ReturnNode { return 'return ${sequence(it.rhs)}' }
    AssignNode {
      l := sequence(it.lhs)
      r := sequence(it.rhs)
      return '$l := $r'
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
  }
}

struct Lvar {
  pub mut:
  name string
  offset int
  next &Lvar
}

fn new_lvar(name string, offset int) &Lvar {
  return &Lvar{name, offset, 0}
}

pub fn (p &Parser) get_lvar_offset(name string) int {
  mut l := p.head_lvar
  for {
    if l.name == name {
      return l.offset
    }
    if l.next == 0 {break}
    l = l.next
  }
  panic('Error: can not find local variable')
}

struct Parser {
  pub mut:
  token token.Token
  program []Node
  head_lvar &Lvar
  tail_lvar &Lvar
}

pub fn new_parser(tk token.Token) &Parser {
  l := &Lvar{'', 0, 0}
  return &Parser{token: tk, head_lvar: l, tail_lvar: l}
}

pub fn (p &Parser) parse() {
  p.program = p.program()
}

fn (p &Parser) program() []Node {
  mut stmts := []Node{}
  for p.token.kind != .eof {
    stmts << p.stmt()
  }
  return stmts
}

fn (p &Parser) stmt() Node {
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
  node := p.expr()
  return node
}

fn (p &Parser) expr() Node {
  node := p.assign()
  return node
}

fn (p &Parser) assign() Node {
  mut node := p.equality()
  if p.token.consume(':=') {
    node = new_assign_node(node, p.assign())
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
    } else if p.token.consume('>'){
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
    } else if p.token.consume('/'){
      node = new_infix_node(.div, '/', node, p.unary())
    } else {
      return node
    }
  }
}

fn (p &Parser) unary() Node {
  if p.token.consume('+'){
    return p.primary()
  } else if p.token.consume('-'){
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
    p.tail_lvar.next = new_lvar(p.token.str, p.tail_lvar.offset + 8)
    p.tail_lvar = p.tail_lvar.next
    node := new_lvar_node(p.token.str, p.tail_lvar.offset + 8)
    p.token.next_token()
    return node
  }

  return new_num_node(p.token.expect_number())
}
