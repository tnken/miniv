
module parser

struct Lvar {
pub mut:
	name   string
	offset int
	next   &Lvar
}

fn new_lvar(name string, offset int) &Lvar {
	return &Lvar{name, offset, 0}
}
