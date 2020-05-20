import os

fn compile(source string) int {
	os.exec('./tinyv $source > tmp.s') or {
		println('error: compile error')
		panic(err)
	}
	os.exec('gcc -o tmp tmp.s') or {
		println('error: compile error')
		panic(err)
	}
	res := os.exec('./tmp') or {
		println('error: compile error')
		panic(err)
	}
	return res.exit_code
}

fn test_compiler() {
	cases := [
		[1, 1],
		[2, 2],
		[3, 3],
		[4, 4]
	]

	for c in cases {
		assert compile(c[0].str()) == c[1]
	}
}
