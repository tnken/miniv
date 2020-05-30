import os

fn compile(source string) int {
  os.exec('./miniv \'$source\' > tmp.s') or {
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

fn display_result(idx int, ok bool) {
  if ok {
    println('[ok]: ${idx}')
  } else {
    println('[faile]: ${idx}')
  }
}

struct Case {
  input string
  expecting int
}

fn test_calculation() {
  cases := [
    Case{'2', 2},
    Case{'1+0', 1},
    Case{'1-1', 0},
    Case{'3-2+3', 4},
    Case{'3+3-4', 2},
    Case{'3+3-4+3', 5},
    Case{'1*2', 2},
    Case{'4/2', 2},
    Case{'(1+1)*5', 10},
    Case{'(2+2)/2', 2},
    Case{'10-(3+3)', 4},
    Case{'6/2+3*(2+5/(1+6))-2', 7},
    Case{'-4+16', 12},
    Case{'-((8+8)/2) + 12', 4},
    Case{'1 == 1', 1},
    Case{'0 == 1', 0},
    Case{'1 == 0', 0},
    Case{'0 == 0', 1},
    Case{'1 != 1', 0},
    Case{'0 != 1', 1},
    Case{'1 != 0', 1},
    Case{'0 != 0', 0},
    Case{'1 > 1', 0},
    Case{'0 > 1', 0},
    Case{'1 > 0', 1},
    Case{'0 > 0', 0},
    Case{'1 >= 1', 1},
    Case{'0 >= 1', 0},
    Case{'1 >= 0', 1},
    Case{'0 >= 0', 1},
    Case{'1 < 1', 0},
    Case{'0 < 1', 1},
    Case{'1 < 0', 0},
    Case{'0 < 0', 0},
    Case{'1 <= 1', 1},
    Case{'0 <= 1', 1},
    Case{'1 <= 0', 0},
    Case{'0 <= 0', 1},
  ]

  for idx, c in cases {
    expected := c.expecting
    output := compile(c.input)
    assert expected == output
    display_result(idx, expected == output)
  }
}

fn test_lvar() {
  cases := [
    Case{'a:=2', 2},
    Case{'a:=2 b:=1 c:=a-b', 1},
    Case{'a:=2 b:=1 c:=a-b 0', 0},
    Case{'a:=1 b:=2 c:=3 a+b+c', 6},
    Case{'hoge := 1 fuga := 2 hoge+fuga', 3},
    Case{'hoge := 1 fuga := 2 vv := fuga-hoge (hoge+fuga)*2-vv', 5}
  ]

   for idx, c in cases {
    expected := c.expecting
    output := compile(c.input)
    assert expected == output
    display_result(idx, expected == output)
  }
}

fn test_return() {
  cases := [
    Case{'return 1+1-1-1', 0},
    Case{'return (3+3)*2', 12},
    Case{'a:=1 return a', 1},
    Case{'a:=1 b:=2 return a', 1},
    Case{'a:=1 b:=2 return a + 5', 6},
    Case{'hoge:=1 fuga:=2 poge := 3 return (hoge+fuga)*2', 6}
    Case{'a:=1 return a 3', 1},
    Case{'a:=1 return a hoge := 2 return hoge', 1},
    Case{'a:=1 a=a+1 a=a+1 return a a=a+1', 3},
  ]

   for idx, c in cases {
    expected := c.expecting
    output := compile(c.input)
    assert expected == output
    display_result(idx, expected == output)
  }
}

fn test_if() {
  cases := [
    Case{'if 1 return 3', 3},
    Case{'if 1 return 1 1+1', 1},
    Case{'if 0 return 1 1+1', 2},
    Case{'hoge := 1 if 2-1 hoge', 1},
    Case{'hoge := 1 if hoge return 2 else 3', 2},
    Case{'hoge := 0 if hoge return 2 else 3', 3},
    Case{'a:=3 if 0 a+4 else a-1', 2},
    Case{'a:=1 if 1 a+4 else a-1', 5},
    Case{'a:=1 if 2 if 0 a+1 else a+2 else 4', 3}
  ]

   for idx, c in cases {
    expected := c.expecting
    output := compile(c.input)
    assert expected == output
    display_result(idx, expected == output)
  }
}

fn test_for() {
  cases := [
    Case{'a := 1 for a < 10 a = a + 1 a', 10},
    Case{'a := 11 for a < 10 a = a + 1 a', 11},
    Case{'a := 11 for a > 0 a = a - 1 a', 0},
    Case{'a := 0 for i := 0; i < 3; i=i+1 a=a+1 a', 3},
    Case{'a := 0 for i := 0; i < 3; i=i+1 a=a+2 a', 6},
    Case{'a := 0 for i := 0; i < 10; i=i+1 a=a+1 a', 10}
    Case{'a := 10 for i := 5; i > 0; i=i-1 a=a+1 a', 15},
    Case{'a := 0 for i := 0; i < 100; i=i+10 a=a+1 a', 10},
  ]

   for idx, c in cases {
    expected := c.expecting
    output := compile(c.input)
    // println(output)
    assert expected == output
    display_result(idx, expected == output)
  }
}
