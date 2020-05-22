import os

fn compile(source string) int {
  os.exec('./tinyv \'$source\' > tmp.s') or {
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
