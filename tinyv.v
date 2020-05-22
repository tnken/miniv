module main

import os
import token
import parser
import codegen

fn main(){
	if os.args.len == 1 {
		println('error: argument is missing')
		return
	}
	tok := token.tokenize(os.args[1])
	println('.global main')
  println('main:')

	p := parser.new_parser(tok)
	node := p.parse()
	codegen.gen(node)

	println('  pop %rax')
  println('  ret')
}
