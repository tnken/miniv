module parser

import token

enum NodeKind {
  add      // +
  sub      // -
  mul      // *
  div      // /
  num      // number
  lt       // <
  le       // <=
  eq       // ==
  ne       // !=
  assign   // :=
  lvar     // hoge
}

struct Node {
  pub mut:
  kind NodeKind
  str string
  val int
  lhs &Node
  rhs &Node
  offset int
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

pub fn (p &Parser) find_lvar(name string) &Lvar {
  mut l := p.head_lvar
  for {
    if l.name == name {
      return l
    }
    if l.next == 0 {break}
    l = l.next
  }
  return 0
}

pub fn (n Node) string() string {
  if n.kind == .num {
    return n.val.str()
  } else {
    return n.str
  }
}

pub struct Parser {
  pub mut:
  token token.Token
  program []&Node
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

fn new_node(kind NodeKind, s string, lhs &Node, rhs &Node) &Node {
  return &Node{kind, s, 0, lhs, rhs, 0}
}

fn new_node_num(val int) &Node {
  return &Node{.num, '', val, 0, 0, 0}
}

fn (p &Parser) program() []&Node {
  mut stmts := []&Node{}
  for p.token.kind != .eof {
    stmts << p.stmt()
  }
  return stmts
}

fn (p &Parser) stmt() &Node {
  node := p.expr()
  return node
}

fn (p &Parser) expr() &Node {
  node := p.assign()
  return node
}

fn (p &Parser) assign() &Node {
  node := p.equality()
  if p.token.consume(':=') {
    node = new_node(.assign, ':=', node, p.assign())
  }
  return node
}

fn (p &Parser) equality() &Node {
  node := p.relational()

  for {
    if p.token.consume('==') {
      node = new_node(.eq, '==', node, p.relational())
    } else if p.token.consume('!=') {
      node = new_node(.ne, '!=', node, p.relational())
    } else {
      return node
    }
  }
}

fn (p &Parser) relational() &Node {
  node := p.add()

  for {
    if p.token.consume('<') {
      node = new_node(.lt, '<', node, p.add())
    } else if p.token.consume('>'){
      node = new_node(.lt, '>', p.add(), node)
      } else if p.token.consume('<=') {
      node = new_node(.le, '<=', node, p.add())
    } else if p.token.consume('>=') {
      node = new_node(.le, '>=', p.add(), node)
    } else {
      return node
    }
  }
}

fn (p &Parser) add() &Node {
  node := p.mul()

  for {
    if p.token.consume('+') {
      node = new_node(.add, '+', node, p.mul())
    } else if p.token.consume('-') {
      node = new_node(.sub, '-', node, p.mul())
    } else {
      return node
    }
  }
}

fn (p &Parser) mul() &Node {
  node := p.unary()

  for {
    if p.token.consume('*') {
      node = new_node(.mul, '*', node, p.unary())
    } else if p.token.consume('/'){
      node = new_node(.div, '/', node, p.unary())
    } else {
      return node
    }
  }
}

fn (p &Parser) unary() &Node {
  if p.token.consume('+'){
    return p.primary()
  } else if p.token.consume('-'){
    return new_node(.sub, '-', new_node_num(0), p.primary())
  }

  return p.primary()
}

fn (p &Parser) primary() &Node {
  if p.token.consume('(') {
    node := p.expr()
    p.token.expect(')')
    return node
  }

  if p.token.kind == .ident {
    p.tail_lvar.next = new_lvar(p.token.str, p.tail_lvar.offset + 8)
    p.tail_lvar = p.tail_lvar.next
    node := &Node{.lvar, p.token.str, 0, 0, 0, 0}
    p.token.next_token()
    return node
  }

  return new_node_num(p.token.expect_number())
}
