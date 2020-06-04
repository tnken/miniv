module codegen

import parser
import os

fn prologue() {
	println('  push %rbp')
	println('  mov %rsp, %rbp')
	println('  sub $208, %rsp')
}

fn epilogue() {
	println('  mov %rbp, %rsp')
	println('  pop %rbp')
	println('  ret')
}

pub fn gen_program(p &parser.Parser) {
	builtin := os.read_file('./builtin.s') or {
		println('Failed to open builtin.s')
		return
	}
	println(builtin)
	println('.global main')
	println('.text')

	mut cg := Cgen{p}
	for node in p.program {
		cg.gen(node)
	}
}

struct Cgen {
	p           parser.Parser
mut:
	label_seq int
}

fn (mut cg Cgen) gen_print(node parser.FuncCallNode) {
	// TODO: increase the number of argument
	// only one argument is allowed now
	resi := ['rdi']
	for i, arg in node.args {
		cg.gen(arg)
		println('  pop %rax')
		println('  mov %rax, %${resi[i]}')
	}
	// TODO: to be able to print other type
	// only number can be printed now
	println('  call builtin.print_uint')
	println('  call builtin.print_newline')
	println('  push %rax')
}

fn (cg Cgen) gen_lvar(node parser.Node) {
	match node {
		parser.LvarNode {
			println('  mov %rbp, %rax')
			offset := cg.p.get_lvar_offset(it.str)
			println('  sub $$offset, %rax')
			println('  push %rax')
		}
		else {
			panic('Error: not local variable')
		}
	}
}

fn (mut cg Cgen) gen(node parser.Node) {
	match node {
		parser.NumNode {
			println('  push $$it.val')
			return
		}
		parser.LvarNode {
			cg.gen_lvar(node)
			println('  pop %rax')
			println('  mov (%rax), %rax')
			println('  push %rax')
			return
		}
		parser.ReturnNode {
			cg.gen(it.rhs)
			println('  pop %rax')
			epilogue()
			return
		}
		parser.AssignNode {
			cg.gen_lvar(it.lhs)
			cg.gen(it.rhs)
			println('  pop %rdi')
			println('  pop %rax')
			println('  mov %rdi, (%rax)')
			println('  push %rdi')
			return
		}
		parser.DeclareNode {
			cg.gen_lvar(it.lhs)
			cg.gen(it.rhs)
			println('  pop %rdi')
			println('  pop %rax')
			println('  mov %rdi, (%rax)')
			println('  push %rdi')
			return
		}
		parser.IfNode {
			cg.gen(it.condition)
			println('  pop %rax')
			println('  cmp $0, %rax')
			if it.has_alternative {
				println('  je LELSE${cg.label_seq}')
				cg.gen(it.consequence)
				println('  jmp LEND${cg.label_seq}')
				println('LELSE${cg.label_seq}:')
				cg.gen(it.alternative)
			} else {
				println('  je LEND${cg.label_seq}')
				cg.gen(it.consequence)
			}
			println('LEND${cg.label_seq}:')
			cg.label_seq++
			return
		}
		parser.ForNode {
			if it.is_cstyle {
				cg.gen(it.init)
				println('  pop %rax')
				println('LSTART$cg.label_seq:')
				cg.gen(it.condition)
				println('  pop %rax')
				println('  cmp $0, %rax')
				println('  je LEND${cg.label_seq}')
				cg.gen(it.consequence)
				cg.gen(it.increment)
				println('  jmp LSTART$cg.label_seq')
				println('LEND$cg.label_seq:')
			} else {
				println('LSTART$cg.label_seq:')
				cg.gen(it.condition)
				println('  pop %rax')
				println('  cmp $0, %rax')
				println('  je LEND$cg.label_seq')
				cg.gen(it.consequence)
				println('  jmp LSTART$cg.label_seq')
				println('LEND$cg.label_seq:')
			}
			cg.label_seq++
			return
		}
		parser.BlockNode {
			for stmt in it.stmts {
				cg.gen(stmt)
				println('  pop %rax')
			}
			return
		}
		parser.FuncNode {
			println('$it.name:')
			prologue()
			// TODO: extend the number of argument
			if it.args.len > 0 {
				cg.gen_lvar(it.args[0])
				println('  pop %rax')
				println('  mov %rdi, (%rax)')
				println('  push %rdi')
			}
			cg.gen(it.block)
			epilogue()
		}
		parser.FuncCallNode {
			if it.ident in ['println'] {
				cg.gen_print(it)
				return
			}
			resi := ['rdi']
			for i, arg in it.args {
				cg.gen(arg)
				println('  pop %rax')
				println('  mov %rax, %${resi[i]}')
			}
			println('  call $it.ident')
			println('  push %rax')
		}
		parser.InfixNode {
			cg.gen(it.lhs)
			cg.gen(it.rhs)
			println('  pop %rdi')
			println('  pop %rax')
			match it.kind {
				.add {
					println('  add %rdi, %rax')
				}
				.sub {
					println('  sub %rdi, %rax')
				}
				.mul {
					println('  imul %rdi, %rax')
				}
				.div {
					println('  cqo')
					println('  idiv %rdi')
				}
				.eq {
					println('  cmp %rdi, %rax')
					println('  sete %al')
					println('  movzb %al, %rax')
				}
				.ne {
					println('  cmp %rdi, %rax')
					println('  setne %al')
					println('  movzb %al, %rax')
				}
				.lt {
					println('  cmp %rdi, %rax')
					println('  setl %al')
					println('  movzb %al, %rax')
				}
				.le {
					println('  cmp %rdi, %rax')
					println('  setle %al')
					println('  movzb %al, %rax')
				}
			}
			println('  push %rax')
		}
	}
}
