import token

struct ExpectToken {
  kind token.TokenKind
  val int
  str string
}

fn display_result(idx int, ok bool) {
  if ok {
    println('[ok]: ${idx}')
  } else {
    println('[faile]: ${idx}')
  }
}

fn test_tokenizer() {
  input := [
    ' 11   ',
    ' 1 + 1 '
    '1-1',
    '1000+100000-1',
    ' 1000  + 100000 - 1  ',
    '(1+1) * 3',
    '3==3',
    '5>=3',
  ]

  expecting := [
    [
      ExpectToken{.num, 11, ''},
      ExpectToken{.eof}
    ],
    [
      ExpectToken{.num, 1, ''},
      ExpectToken{.reserved, 0, '+'},
      ExpectToken{.num, 1, ''},
      ExpectToken{.eof}
    ],
    [
      ExpectToken{.num, 1, ''},
      ExpectToken{.reserved, 0, '-'},
      ExpectToken{.num, 1, ''},
      ExpectToken{.eof}
    ],
    [
      ExpectToken{.num, 1000, ''},
      ExpectToken{.reserved, 0, '+'},
      ExpectToken{.num, 100000, ''},
      ExpectToken{.reserved, 0, '-'},
      ExpectToken{.num, 1, ''},
      ExpectToken{.eof}
    ],
      [
      ExpectToken{.num, 1000, ''},
      ExpectToken{.reserved, 0, '+'},
      ExpectToken{.num, 100000, ''},
      ExpectToken{.reserved, 0, '-'},
      ExpectToken{.num, 1, ''},
      ExpectToken{.eof}
    ],
    [
      ExpectToken{.reserved, 0, '('},
      ExpectToken{.num, 1, ''},
      ExpectToken{.reserved, 0, '+'},
      ExpectToken{.num, 1, ''},
      ExpectToken{.reserved, 0, ')'},
      ExpectToken{.reserved, 0, '*'},
      ExpectToken{.num, 3, ''},
      ExpectToken{.eof}
    ],
    [
      ExpectToken{.num, 3, ''},
      ExpectToken{.reserved, 0, '=='},
      ExpectToken{.num, 3, ''},
      ExpectToken{.eof}
    ],
    [
      ExpectToken{.num, 5, ''},
      ExpectToken{.reserved, 0, '>='},
      ExpectToken{.num, 3, ''},
      ExpectToken{.eof}
    ]
  ]

  for idx, s in input {
    mut tk := token.tokenize(s)
    mut i := 0

    for tk.kind != .eof {
      expected := expecting[idx][i++]

      assert expected.kind == tk.kind
      display_result(idx, expected.kind == tk.kind)
      if expected.kind == .num {
        assert expected.val == tk.val
        display_result(idx, expected.val == tk.val)
      } else if expected.kind == .reserved {
        assert expected.str == tk.str
        display_result(idx, expected.str == tk.str)
      }

      tk = tk.next
    }
  }
}