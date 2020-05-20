import os

fn main(){
	if os.args.len == 1 {
		println('error: argument is missing')
		return
	}

	println('.intel_syntax noprefix')
	println('.global main')
  println('main:')
  println('mov rax, ' + os.args[1])
  println('ret')
}
