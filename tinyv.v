module main

import os
import token

fn main(){
	if os.args.len == 1 {
		println('error: argument is missing')
		return
	}
	mut tok := token.tokenize(os.args[1])
	println('.global main')
  println('main:')
	println('  mov $${tok.expect_number()}, %rax')

	for tok.kind != .eof {
		if tok.consume('+') {
			println('  add $${tok.expect_number()}, %rax')
		}

		if tok.consume('-') {
			println('  sub $${tok.expect_number()}, %rax')
		}

	}

  println('ret')
}
