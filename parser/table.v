module parser

struct Table {
pub mut:
	lvar map[string]Lvar
	latest_lvar Lvar
}

struct Lvar {
pub:
	name   string
	offset int
	// typ Type
	// is_array bool
	// len int
	// caps int
}

fn (t &Table) enter_lvar(name string) Lvar {
	lvar := Lvar{name: name, offset: t.latest_lvar.offset + 8}
	t.lvar[name] = lvar
	t.latest_lvar = lvar
	return lvar
}

fn (t &Table) search_lvar(name string) bool {
	return name in t.lvar
}
