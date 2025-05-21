import gleam/bit_array
import gleam/dict
import gleeunit/should
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
    Ok(#(s, b)) -> b |> mutf8.string_from_bitarray() |> should.equal(Ok(s))
    Error(_) -> panic as { "Missing from bit array test case: " <> c }
  }
}

fn from_string_case(c: String) {
  case cases() |> dict.get(c) {
    Ok(#(s, b)) ->
      s
      |> mutf8.bitarray_from_string()
      |> bit_array.inspect()
      |> should.equal(b |> bit_array.inspect())
    Error(_) -> panic as { "Missing from bit array test case: " <> c }
  }
}

// From bit_array

pub fn null_from_bitarray_test() {
  "null" |> from_bit_array_case
}

pub fn latin_2_with_stroke_from_bitarray_test() {
  "latin_2_with_stroke" |> from_bit_array_case
}

pub fn canadian_syllabics_e_from_bitarray_test() {
  "canadian_syllabics_e" |> from_bit_array_case
}

pub fn square_kb_from_bitarray_test() {
  "square_kb" |> from_bit_array_case
}

pub fn katakana_tu_from_bitarray_test() {
  "katakana_tu" |> from_bit_array_case
}

pub fn korean_from_bitarray_test() {
  "korean" |> from_bit_array_case
}

pub fn deseret_long_e_capital_from_bitarray_test() {
  "deseret_long_e_capital" |> from_bit_array_case
}

pub fn deseret_short_a_capital_from_bitarray_test() {
  "deseret_short_a_capital" |> from_bit_array_case
}

// From string

pub fn null_from_string_test() {
  "null" |> from_string_case
}

pub fn latin_2_with_stroke_from_string_test() {
  "latin_2_with_stroke" |> from_string_case
}

pub fn canadian_syllabics_e_from_string_test() {
  "canadian_syllabics_e" |> from_string_case
}

pub fn square_kb_from_string_test() {
  "square_kb" |> from_string_case
}

pub fn katakana_tu_from_string_test() {
  "katakana_tu" |> from_string_case
}

pub fn korean_from_string_test() {
  "korean" |> from_string_case
}

pub fn deseret_long_e_capital_from_string_test() {
  "deseret_long_e_capital" |> from_string_case
}

pub fn deseret_short_a_capital_from_string_test() {
  "deseret_short_a_capital" |> from_string_case
}
