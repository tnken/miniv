module parser

enum TypeKind {
	type_int
	type_struct
}

struct Type {
	name string
	kind TypeKind
}

fn new_type(name string) Type {
	match name {
		'int' {
			return Type{name: name, kind: .type_int}
		}
		else {
			return Type{name: name, kind: .type_struct}
		}
	}
}
