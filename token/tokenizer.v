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

fn (mut s Scanner) scan_advance(i int) bool{
  s.pos += i
  if s.pos < s.input.len {
    s.ch = s.input[s.pos]
  } else {
    return false
  }
  return true
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
  ident
}

struct Token {
  pub mut:
    kind TokenKind
    next &Token
    val int
    str string
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
    kind: kind,
    str: str,
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

pub fn (t &Token) consume_ident() &Token {
  if t.kind != .ident {
    return 0
  }
  tok := t
  t.next_token()
  return tok
}

pub fn (t &Token) expect(op string) {
  if t.kind != .reserved || t.str != op {
    panic('error: not expected operator')
  }
  t.next_token()
}

pub fn (t &Token) expect_number() int {
  if t.kind != .num {
    panic('error: not expected operator')
  }
  val := t.val
  t.next_token()
  return val
}

pub fn tokenize(input string) &Token{
  head := &Token{next: 0}
  cur := head
  mut sc := new_scanner(input)

  for sc.pos < sc.input.len {
    if !sc.skip_whitespace() {
      continue
    }

    if sc.pos < sc.input.len-1 {
      target := sc.input[sc.pos..sc.pos+2]
      if  target == '==' || target == '!=' {
        cur = new_token(.reserved, cur, target)
        sc.scan_advance(2)
        continue
      }

      if target == '<=' || target == '>=' {
        cur = new_token(.reserved, cur, target)
        sc.scan_advance(2)
        continue
      }

      if target == ':=' {
        cur = new_token(.reserved, cur, target)
        sc.scan_advance(2)
        continue
      }
    }

    if sc.ch.str() in '+-*/()<>' {
      cur = new_token(.reserved, cur, sc.ch.str())
      sc.scan_advance(1)
      continue
    }

    if sc.ch.is_digit() {
      cur = new_token(.num, cur, '')
      cur.val = sc.scan_num()
      continue
    }

    if sc.ch.is_letter() {
      l := sc.pos
      for sc.ch.is_letter() && sc.scan_advance(1) {}
      cur = new_token(.ident, cur, sc.input[l..sc.pos])
      continue
    }

    panic('Syntax Error: undefined token')
  }
  new_token(.eof, cur, '0')
  return head.next
}
