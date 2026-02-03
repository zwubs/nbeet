import gleam/dict
import nbeet/internal/mutf8

fn cases() {
  dict.from_list([
    #("null", #("\u{0000}", <<0xc0, 0x80>>)),
    #("latin_2_with_stroke", #("ƻ", <<0xc6, 0xbb>>)),
    #("canadian_syllabics_e", #("ᐁ", <<0xe1, 0x90, 0x81>>)),
    #("square_kb", #("㎅", <<0xe3, 0x8e, 0x85>>)),
    #("katakana_tu", #("ッ", <<0xe3, 0x83, 0x83>>)),
    #(
      "korean",
      #("한국어로 문자열이에요", <<
        0xed, 0x95, 0x9c, 0xea, 0xb5, 0xad, 0xec, 0x96, 0xb4, 0xeb, 0xa1, 0x9c,
        0x20, 0xeb, 0xac, 0xb8, 0xec, 0x9e, 0x90, 0xec, 0x97, 0xb4, 0xec, 0x9d,
        0xb4, 0xec, 0x97, 0x90, 0xec, 0x9a, 0x94,
      >>),
    ),
    #("deseret_long_e_capital", #("𐐁", <<0xED, 0xA0, 0x81, 0xED, 0xB0, 0x81>>)),
    #("deseret_short_a_capital", #("𐐈", <<0xED, 0xA0, 0x81, 0xED, 0xB0, 0x88>>)),
  ])
}

fn from_bit_array_case(c: String) {
  case cases() |> dict.get(c) {
    Ok(#(s, b)) -> {
      #(Ok(s), b |> mutf8.string_from_bitarray())
    }
    Error(_) -> panic as { "Missing from bit array test case: " <> c }
  }
}

fn from_string_case(c: String) {
  case cases() |> dict.get(c) {
    Ok(#(s, b)) -> {
      #(Ok(b), s |> mutf8.bitarray_from_string())
    }
    Error(_) -> panic as { "Missing from bit array test case: " <> c }
  }
}

// From bit_array

pub fn null_from_bitarray_test() {
  let #(s, b) = "null" |> from_bit_array_case
  assert s == b
}

pub fn latin_2_with_stroke_from_bitarray_test() {
  let #(s, b) = "latin_2_with_stroke" |> from_bit_array_case
  assert s == b
}

pub fn canadian_syllabics_e_from_bitarray_test() {
  let #(s, b) = "canadian_syllabics_e" |> from_bit_array_case
  assert s == b
}

pub fn square_kb_from_bitarray_test() {
  let #(s, b) = "square_kb" |> from_bit_array_case
  assert s == b
}

pub fn katakana_tu_from_bitarray_test() {
  let #(s, b) = "katakana_tu" |> from_bit_array_case
  assert s == b
}

pub fn korean_from_bitarray_test() {
  let #(s, b) = "korean" |> from_bit_array_case
  assert s == b
}

pub fn deseret_long_e_capital_from_bitarray_test() {
  let #(s, b) = "deseret_long_e_capital" |> from_bit_array_case
  assert s == b
}

pub fn deseret_short_a_capital_from_bitarray_test() {
  let #(s, b) = "deseret_short_a_capital" |> from_bit_array_case
  assert s == b
}

// From string

pub fn null_from_string_test() {
  let #(b, s) = "null" |> from_string_case
  assert b == s
}

pub fn latin_2_with_stroke_from_string_test() {
  let #(b, s) = "latin_2_with_stroke" |> from_string_case
  assert b == s
}

pub fn canadian_syllabics_e_from_string_test() {
  let #(b, s) = "canadian_syllabics_e" |> from_string_case
  assert b == s
}

pub fn square_kb_from_string_test() {
  let #(b, s) = "square_kb" |> from_string_case
  assert b == s
}

pub fn katakana_tu_from_string_test() {
  let #(b, s) = "katakana_tu" |> from_string_case
  assert b == s
}

pub fn korean_from_string_test() {
  let #(b, s) = "korean" |> from_string_case
  assert b == s
}

pub fn deseret_long_e_capital_from_string_test() {
  let #(b, s) = "deseret_long_e_capital" |> from_string_case
  assert b == s
}

pub fn deseret_short_a_capital_from_string_test() {
  let #(b, s) = "deseret_short_a_capital" |> from_string_case
  assert b == s
}
