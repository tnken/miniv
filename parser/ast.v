module parser

enum NodeKind {
  add        // +
  sub        // -
  mul        // *
  div        // /
  lt         // <
  le         // <=
  eq         // ==
  ne         // !=
  assign     // :=
  num        // number
  lvar       // hoge
  nd_return  // return
  nd_if      // if
  nd_for     // for
}

type Node = InfixNode | NumNode | LvarNode | AssignNode | ReturnNode |
            IfNode | ForNode | DeclareNode

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

struct DeclareNode {
  pub:
  kind NodeKind
  lhs Node
  rhs Node
}

fn new_declare_node(lhs Node, rhs Node) Node {
  return DeclareNode{.assign, lhs, rhs}
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

struct ForNode {
  pub:
  kind NodeKind
  init Node
  condition Node
  increment Node
  consequence Node
  is_cstyle bool
}

fn new_for_node(cond Node, cons Node) ForNode {
  return ForNode {
    kind: .nd_for
    condition: cond
    consequence: cons
    is_cstyle: false
  }
}

fn new_cstyle_for_node(init Node, cond Node, inc Node, cons Node) ForNode {
  return ForNode {
    kind: .nd_for
    init: init
    condition: cond
    increment: inc
    consequence: cons
    is_cstyle: true
  }
}
