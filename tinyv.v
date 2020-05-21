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
	tok = tok.next

	for tok.token_kind != .eof {
		if tok.consume('+') {
			tok = tok.next
			println('  add $${tok.expect_number()}, %rax')
		}

		if tok.consume('-') {
			tok = tok.next
			println('  sub $${tok.expect_number()}, %rax')
		}
		tok = tok.next
	}

	// for sc.pos < sc.text.len {
	// 	if sc.text[sc.pos] == `+` {
	// 		sc.pos++
	// 		println('  add $${sc.text[sc.pos..sc.pos+1].int()}, %rax')
	// 		sc.pos++
	// 		continue
	// 	}

	// 	if sc.text[sc.pos] == `-` {
	// 		sc.pos++
	// 		println('  sub $${sc.text[sc.pos..sc.pos+1].int()}, %rax')
	// 		sc.pos++
	// 		continue
	// 	}

	// 	println('error: unexpected token')
	// 	return
	// }

  println('ret')
}
