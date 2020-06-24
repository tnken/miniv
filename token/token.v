module token

struct Scanner {
mut:
	pos   int
	input string
	ch    byte
}

fn new_scanner(input string) &Scanner {
	return &Scanner{
		pos: 0
		input: input
		ch: input[0]
	}
}

fn (s &Scanner) skip_whitespace() bool {
	for s.input[s.pos].is_space() {
		s.pos++
		if s.pos == s.input.len {
			return false
		}
	}
	if s.pos < s.input.len {
		s.ch = s.input[s.pos]
	} else {
		s.ch = ` `
	}
	return true
}

fn (mut s Scanner) scan_advance(i int) bool {
	s.pos += i
	if s.pos < s.input.len {
		s.ch = s.input[s.pos]
	} else {
		return false
	}
	return true
}

fn is_alnum(b byte) bool{
	return b.is_letter() || b.is_digit()
}

fn (mut s Scanner) scan_num() int {
	start := s.pos
	for s.ch.is_digit() && s.pos < s.input.len {
		s.pos++
		if s.pos < s.input.len {
			s.ch = s.input[s.pos]
		}
	}
	return s.input[start..s.pos].int()
}

pub enum TokenKind {
	reserved
	num
	text
	eof
	ident
}

struct Token {
pub mut:
	kind TokenKind
	next &Token
	val  int
	str  string
}

pub fn (t &Token) next_token() {
	next := t.next
	t.kind = next.kind
	t.val = next.val
	t.str = next.str
	t.next = next.next
}

fn new_token(kind TokenKind, cur &Token, str string) &Token {
	token := &Token{
		kind: kind
		str: str
		next: 0
	}
	cur.next = token
	return token
}

pub fn (t &Token) consume(op string) bool {
	if t.kind != .reserved || t.str != op {
		return false
	}
	t.next_token()
	return true
}

pub fn (t &Token) expect(op string) {
	if t.kind != .reserved || t.str != op {
		panic('error: not expected operator')
	}
	t.next_token()
}

pub fn (t &Token) expect_ident() string {
	if t.kind != .ident {
		panic('error: not expected identifier')
	}
	s := t.str
	t.next_token()
	return s
}

pub fn (t &Token) expect_number() int {
	if t.kind != .num {
		panic('error: not expected operator')
	}
	val := t.val
	t.next_token()
	return val
}

pub fn (t &Token) expect_text() string {
	if t.kind != .text {
		panic('error: not expected operator')
	}
	str:= t.str
	t.next_token()
	return str
}

fn is_type_name(s string) bool {
	return s in ['int']
}

pub fn (t &Token) expect_type_name() string {
	if t.kind != .reserved || !(is_type_name(t.str)) {
		panic('error: not expected type')
	}
	s := t.str
	t.next_token()
	return s
}

pub fn tokenize(input string) &Token {
	head := &Token{
		next: 0
	}
	cur := head
	mut sc := new_scanner(input)
	for sc.pos < sc.input.len {
		if !sc.skip_whitespace() {
			continue
		}
		mut should_continue := false
		operators := [
			'==',
			'!=',
			'<=',
			'>=',
			':='
		]
		for op in operators {
			if sc.pos < sc.input.len - (op.len - 1) {
				target := sc.input[sc.pos..sc.pos + op.len]
				if target == op {
					cur = new_token(.reserved, cur, op)
					sc.scan_advance(op.len)
					should_continue = true
					break
				}
			}
		}
		if should_continue {
			continue
		}

		keywords := [
			'if',
			'for',
			'else',
			'return',
			'fn',
			'int',
			'string'
		]
		for key in keywords {
			if sc.pos < sc.input.len - (key.len - 1) {
				target := sc.input[sc.pos..sc.pos + key.len]
				mut is_lvar := false
				if sc.pos + key.len < sc.input.len {
					if is_alnum(sc.input[sc.pos + key.len]) {
						// ex. iflvar := 3
						is_lvar = true
					}
				}
				if target == key && !is_lvar {
					cur = new_token(.reserved, cur, key)
					sc.scan_advance(key.len)
					should_continue = true
					break
				}
			}
		}
		if should_continue {
			continue
		}

		if sc.ch.str() in '+-*/()<>=;{},[]' {
			cur = new_token(.reserved, cur, sc.ch.str())
			sc.scan_advance(1)
			continue
		}
		if sc.ch.is_digit() {
			cur = new_token(.num, cur, '')
			cur.val = sc.scan_num()
			continue
		}
		if sc.ch.str() in '\'' {
			cur = new_token(.reserved, cur, '\'')
			sc.scan_advance(1)
			l := sc.pos
			for (sc.ch.str() != '\'') && sc.scan_advance(1) {}
			cur = new_token(.text, cur, sc.input[l..sc.pos])
			cur = new_token(.reserved, cur, '\'')
			sc.scan_advance(1)
			continue
		}
		if sc.ch.is_letter() {
			l := sc.pos
			for (is_alnum(sc.ch) || sc.ch == `_`) && sc.scan_advance(1) {}
			cur = new_token(.ident, cur, sc.input[l..sc.pos])
			continue
		}
		panic('Syntax Error: undefined token')
	}
	new_token(.eof, cur, '0')
	return head.next
}
