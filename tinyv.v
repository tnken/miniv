import os

fn main(){
	if os.args.len == 1 {
		println('error: argument is missing')
		return
	}
	arg := os.args[1]

	println('.global main')
  println('main:')
  println('movq $$arg, %rax')
  println('ret')
}
