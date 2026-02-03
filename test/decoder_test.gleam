import gleam/dict
import gleam/dynamic/decode
import nbeet/nbt
import simplifile

pub type IntegerTest {
  IntegerTest(value: Int, zero: Int, min: Int, max: Int)
}

fn integer_test_decoder(field_prefix: String) {
  use value <- decode.field(field_prefix, decode.int)
  use zero <- decode.field(field_prefix <> "_zero", decode.int)
  use min <- decode.field(field_prefix <> "_min", decode.int)
  use max <- decode.field(field_prefix <> "_max", decode.int)
  decode.success(IntegerTest(value, zero, min, max))
}

pub fn decode_byte_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/byte_test.nbt")
  let decoder = integer_test_decoder("byte")
  let assert Ok(#(_, byte_test)) = nbt.java_decode(nbt, decoder)
  assert byte_test.value == 42
  assert byte_test.zero == 0
  assert byte_test.min == -128
  assert byte_test.max == 127
}

pub fn decode_short_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/short_test.nbt")
  let decoder = integer_test_decoder("short")
  let assert Ok(#(_, short_test)) = nbt.java_decode(nbt, decoder)
  assert short_test.value == 42
  assert short_test.zero == 0
  assert short_test.min == -32_768
  assert short_test.max == 32_767
}

pub fn decode_int_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/int_test.nbt")
  let decoder = integer_test_decoder("int")
  let assert Ok(#(_, int_test)) = nbt.java_decode(nbt, decoder)
  assert int_test.value == 42
  assert int_test.zero == 0
  assert int_test.min == -2_147_483_648
  assert int_test.max == 2_147_483_647
}

pub fn decode_long_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/long_test.nbt")
  let decoder = integer_test_decoder("long")
  let assert Ok(#(_, long_test)) = nbt.java_decode(nbt, decoder)
  assert long_test.value == 42
  assert long_test.zero == 0
  assert long_test.min == -9_223_372_036_854_775_808
  assert long_test.max == 9_223_372_036_854_775_807
}

pub type DecimalTest {
  DecimalTest(
    value: Float,
    zero: Float,
    min: Float,
    max: Float,
    infinitesimal: Float,
  )
}

fn decimal_test_decoder(field_prefix: String) {
  use value <- decode.field(field_prefix, decode.float)
  use zero <- decode.field(field_prefix <> "_zero", decode.float)
  use min <- decode.field(field_prefix <> "_min", decode.float)
  use max <- decode.field(field_prefix <> "_max", decode.float)
  use infinitesimal <- decode.field(
    field_prefix <> "_infinitesimal",
    decode.float,
  )
  decode.success(DecimalTest(value, zero, min, max, infinitesimal))
}

pub fn decode_float_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/float_test.nbt")
  let decoder = decimal_test_decoder("float")
  let assert Ok(#(_, float_test)) = nbt.java_decode(nbt, decoder)
  assert float_test.value == 42.0
  assert float_test.zero == 0.0
  assert float_test.min == -3.4028234663852886e38
  assert float_test.max == 3.4028234663852886e38
  assert float_test.infinitesimal == 1.401298464324817e-45
}

pub fn decode_double_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/double_test.nbt")
  let decoder = decimal_test_decoder("double")
  let assert Ok(#(_, double_test)) = nbt.java_decode(nbt, decoder)
  assert double_test.value == 42.0
  assert double_test.zero == 0.0
  assert double_test.min == -1.7976931348623157e308
  assert double_test.max == 1.7976931348623157e308
  assert double_test.infinitesimal == 4.9406564584124654e-324
}

pub type ByteArrayTest {
  ByteArrayTest(value: BitArray, empty: BitArray, min: BitArray, max: BitArray)
}

fn byte_array_test_decoder() {
  use value <- decode.field("byte_array", decode.bit_array)
  use empty <- decode.field("byte_array_empty", decode.bit_array)
  use min <- decode.field("byte_array_min", decode.bit_array)
  use max <- decode.field("byte_array_max", decode.bit_array)
  decode.success(ByteArrayTest(value, empty, min, max))
}

pub fn decode_byte_array_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/byte_array_test.nbt")
  let decoder = byte_array_test_decoder()
  let assert Ok(#(_, byte_array_test)) = nbt.java_decode(nbt, decoder)
  assert byte_array_test.value == <<42>>
  assert byte_array_test.empty == <<>>
  assert byte_array_test.min == <<0>>
  assert byte_array_test.max == <<255>>
}

pub type StringTest {
  StringTest(value: String, empty: String, emoji: String)
}

fn string_test_decoder() {
  use value <- decode.field("string", decode.string)
  use empty <- decode.field("string_empty", decode.string)
  use emoji <- decode.field("string_emoji", decode.string)
  decode.success(StringTest(value, empty, emoji))
}

pub fn decode_string_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/string_test.nbt")
  let decoder = string_test_decoder()
  let assert Ok(#(_, string_test)) = nbt.java_decode(nbt, decoder)
  assert string_test.value == "42"
  assert string_test.empty == ""
  assert string_test.emoji == "⭐"
}

pub type ListTest {
  ListTest(
    value: List(Int),
    empty: List(Int),
    empty_end: List(Int),
    empty_negative: List(Int),
    nested: List(List(String)),
  )
}

fn list_test_decoder() {
  use value <- decode.field("list", decode.list(decode.int))
  use empty <- decode.field("list_empty", decode.list(decode.int))
  use empty_end <- decode.field("list_empty_end", decode.list(decode.int))
  use empty_negative <- decode.field(
    "list_empty_negative",
    decode.list(decode.int),
  )
  use nested <- decode.field(
    "list_nested",
    decode.list(decode.list(decode.string)),
  )
  decode.success(ListTest(value, empty, empty_end, empty_negative, nested))
}

pub fn decode_list_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/list_decode_test.nbt")
  let decoder = list_test_decoder()
  let assert Ok(#(_, list_test)) = nbt.java_decode(nbt, decoder)
  assert list_test.value == [42]
  assert list_test.empty == []
  // List with an END type id
  assert list_test.empty_end == []
  // List with a negative length
  assert list_test.empty_negative == []
  assert list_test.nested == [["egg"]]
}

pub type ValueCompoundTest {
  ValueCompoundTest(value: Int)
}

fn value_compound_test_decoder() {
  use value <- decode.field("", decode.int)
  decode.success(ValueCompoundTest(value))
}

pub type NestedCompoundTest {
  NestedCompoundTest(nest: String)
}

fn nested_compound_test_decoder() {
  use nest <- decode.field("nest", decode.string)
  decode.success(NestedCompoundTest(nest))
}

pub type NesterCompoundTest {
  NesterCompoundTest(nested: NestedCompoundTest)
}

fn nester_compound_test_decoder() {
  use compound_nested <- decode.field(
    "compound_nested",
    nested_compound_test_decoder(),
  )
  decode.success(NesterCompoundTest(compound_nested))
}

pub type CompoundTest {
  CompoundTest(
    value: ValueCompoundTest,
    empty: dict.Dict(String, Int),
    nester: NesterCompoundTest,
  )
}

fn compound_test_decoder() {
  use compound <- decode.field("compound", value_compound_test_decoder())
  use compound_empty <- decode.field(
    "compound_empty",
    decode.dict(decode.string, decode.int),
  )
  use compound_nester <- decode.field(
    "compound_nester",
    nester_compound_test_decoder(),
  )
  decode.success(CompoundTest(compound, compound_empty, compound_nester))
}

pub fn decode_compound_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/compound_test.nbt")
  let decoder = compound_test_decoder()
  let assert Ok(#(_, compound_test)) = nbt.java_decode(nbt, decoder)
  assert compound_test.value.value == 42
  assert dict.size(compound_test.empty) == 0
  assert compound_test.nester.nested.nest == "egg"
}

pub type ArrayTest {
  ArrayTest(value: List(Int), empty: List(Int))
}

fn array_test_decoder(field_prefix: String) {
  use array <- decode.field(field_prefix <> "_array", decode.list(decode.int))
  use empty <- decode.field(
    field_prefix <> "_array_empty",
    decode.list(decode.int),
  )
  decode.success(ArrayTest(array, empty))
}

pub fn decode_int_array_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/int_array_test.nbt")
  let decoder = array_test_decoder("int")
  let assert Ok(#(_, int_array_test)) = nbt.java_decode(nbt, decoder)
  assert int_array_test.value == [42]
  assert int_array_test.empty == []
}

pub fn decode_long_array_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/long_array_test.nbt")
  let decoder = array_test_decoder("long")
  let assert Ok(#(_, long_array_test)) = nbt.java_decode(nbt, decoder)
  assert long_array_test.value == [42]
  assert long_array_test.empty == []
}
