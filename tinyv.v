import os

struct Scanner {
	mut:
		pos int
		text string
}

fn (mut s Scanner) todigit() int {
	mut digit := ''
	for s.text[s.pos].is_digit() {
		digit += s.text[s.pos..s.pos+1]
		s.pos += 1
	}
	return digit.int()
}

fn main(){
	if os.args.len == 1 {
		println('error: argument is missing')
		return
	}
	mut sc := Scanner{
						text: os.args[1]
						pos: 0
					}

	println('.global main')
  println('main:')
	println('  mov $${sc.text[sc.pos..sc.pos+1]}, %rax')
	sc.pos++

	for sc.pos < sc.text.len {
		if sc.text[sc.pos] == `+` {
			sc.pos++
			println('  add $${sc.text[sc.pos..sc.pos+1].int()}, %rax')
			sc.pos++
			continue
		}

		if sc.text[sc.pos] == `-` {
			sc.pos++
			println('  sub $${sc.text[sc.pos..sc.pos+1].int()}, %rax')
			sc.pos++
			continue
		}

		println('error: unexpected token')
		return
	}

  println('ret')
}
