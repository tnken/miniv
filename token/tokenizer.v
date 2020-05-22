module token

struct Scanner {
	mut:
		pos int
		input string
		ch byte
}

fn new_scanner(input string) &Scanner{
	return &Scanner {
		pos: 0,
		input: input,
		ch: input[0]
	}
}

fn (s &Scanner) skip_whitespace() {
	for s.input[s.pos].is_space() {
		s.pos++
		if s.pos == s.input.len {
			break
		}
	}

	if s.pos < s.input.len {
		s.ch = s.input[s.pos]
	} else {
		s.ch = ` `
	}
}

fn (mut s Scanner) scan_advance() {
	s.pos++
	if s.pos < s.input.len {
	  s.ch = s.input[s.pos]
	}
}

fn (mut s Scanner) scan_num() int {
	start := s.pos
	for s.ch.is_digit() && s.pos < s.input.len{
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
	eof
}

struct Token {
	pub mut:
		token_kind TokenKind
	  next &Token
		val int
		str string
}

fn new_token(kind TokenKind, cur &Token, str string) &Token {
	token := &Token{
		token_kind: kind,
		str: str,
		next: 0
	}
	cur.next = token
	return token
}

pub fn (t &Token) consume(op string) bool {
	if t.token_kind != .reserved || t.str != op {
		return false
	}
	return true
}

pub fn (t &Token) expect_number() int {
	if t.token_kind != .num {
		// TODO: error handling
		println('error: not number')
	}
	val := t.val
	return val
}

pub fn tokenize(input string) &Token{
	head := &Token{next: 0}
	cur := head
	mut sc := new_scanner(input)

	for sc.pos < sc.input.len {
		sc.skip_whitespace()

		if sc.ch == `+` || sc.ch == `-` {
			cur = new_token(.reserved, cur, sc.ch.str())
			sc.scan_advance()
			continue
		}

		if sc.ch.is_digit() {
			cur = new_token(.num, cur, '')
			cur.val = sc.scan_num()
			continue
		}
	}
	new_token(.eof, cur, '0')
	return head.next
}
