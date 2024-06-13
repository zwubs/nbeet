import gleam/dict
import gleam/dynamic
import gleam/io
import gleam/option
import gleeunit/should
import nbeet
import simplifile

pub type NumericTest {
  NumericTest(value: Int, zero: Int, min: Int, max: Int)
}

pub fn decode_byte_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/byte_test.nbt")
  let decoder =
    dynamic.decode4(
      NumericTest,
      dynamic.field("byte", dynamic.int),
      dynamic.field("byte_zero", dynamic.int),
      dynamic.field("byte_min", dynamic.int),
      dynamic.field("byte_max", dynamic.int),
    )
  let #(_, byte_test) = should.be_ok(nbeet.decode(nbt, decoder))
  should.equal(byte_test.value, 42)
  should.equal(byte_test.zero, 0)
  should.equal(byte_test.min, -128)
  should.equal(byte_test.max, 127)
}

pub fn decode_short_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/short_test.nbt")
  let decoder =
    dynamic.decode4(
      NumericTest,
      dynamic.field("short", dynamic.int),
      dynamic.field("short_zero", dynamic.int),
      dynamic.field("short_min", dynamic.int),
      dynamic.field("short_max", dynamic.int),
    )
  let #(_, short_test) = should.be_ok(nbeet.decode(nbt, decoder))
  should.equal(short_test.value, 42)
  should.equal(short_test.zero, 0)
  should.equal(short_test.min, -32_768)
  should.equal(short_test.max, 32_767)
}

pub fn decode_int_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/int_test.nbt")
  let decoder =
    dynamic.decode4(
      NumericTest,
      dynamic.field("int", dynamic.int),
      dynamic.field("int_zero", dynamic.int),
      dynamic.field("int_min", dynamic.int),
      dynamic.field("int_max", dynamic.int),
    )
  let #(_, int_test) = should.be_ok(nbeet.decode(nbt, decoder))
  should.equal(int_test.value, 42)
  should.equal(int_test.zero, 0)
  should.equal(int_test.min, -2_147_483_648)
  should.equal(int_test.max, 2_147_483_647)
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

pub fn decode_float_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/float_test.nbt")
  let decoder =
    dynamic.decode5(
      DecimalTest,
      dynamic.field("float", dynamic.float),
      dynamic.field("float_zero", dynamic.float),
      dynamic.field("float_min", dynamic.float),
      dynamic.field("float_max", dynamic.float),
      dynamic.field("float_infinitesimal", dynamic.float),
    )
  let #(_, float_test) = should.be_ok(nbeet.decode(nbt, decoder))
  should.equal(float_test.value, 42.0)
  should.equal(float_test.zero, 0.0)
  should.equal(float_test.min, -3.4028234663852886e38)
  should.equal(float_test.max, 3.4028234663852886e38)
  should.equal(float_test.infinitesimal, 1.401298464324817e-45)
}

pub fn decode_double_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/double_test.nbt")
  let decoder =
    dynamic.decode5(
      DecimalTest,
      dynamic.field("double", dynamic.float),
      dynamic.field("double_zero", dynamic.float),
      dynamic.field("double_min", dynamic.float),
      dynamic.field("double_max", dynamic.float),
      dynamic.field("double_infinitesimal", dynamic.float),
    )
  let #(_, double_test) = should.be_ok(nbeet.decode(nbt, decoder))
  should.equal(double_test.value, 42.0)
  should.equal(double_test.zero, 0.0)
  should.equal(double_test.min, -1.7976931348623157e308)
  should.equal(double_test.max, 1.7976931348623157e308)
  should.equal(double_test.infinitesimal, 4.9406564584124654e-324)
}

pub type ByteArrayTest {
  ByteArrayTest(value: BitArray, empty: BitArray, min: BitArray, max: BitArray)
}

pub fn decode_byte_array_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/byte_array_test.nbt")
  let decoder =
    dynamic.decode4(
      ByteArrayTest,
      dynamic.field("byte_array", dynamic.bit_array),
      dynamic.field("byte_array_empty", dynamic.bit_array),
      dynamic.field("byte_array_min", dynamic.bit_array),
      dynamic.field("byte_array_max", dynamic.bit_array),
    )
  let #(_, byte_array_test) = should.be_ok(nbeet.decode(nbt, decoder))
  should.equal(byte_array_test.value, <<42>>)
  should.equal(byte_array_test.empty, <<>>)
  should.equal(byte_array_test.min, <<0>>)
  should.equal(byte_array_test.max, <<255>>)
}

pub type StringTest {
  StringTest(value: String, empty: String, emoji: String)
}

pub fn decode_string_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/string_test.nbt")
  let decoder =
    dynamic.decode3(
      StringTest,
      dynamic.field("string", dynamic.string),
      dynamic.field("string_empty", dynamic.string),
      dynamic.field("string_emoji", dynamic.string),
    )
  let #(_, string_test) = should.be_ok(nbeet.decode(nbt, decoder))
  should.equal(string_test.value, "42")
  should.equal(string_test.empty, "")
  should.equal(string_test.emoji, "⭐")
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

pub fn decode_list_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/list_test.nbt")
  let decoder =
    dynamic.decode5(
      ListTest,
      dynamic.field("list", dynamic.list(dynamic.int)),
      dynamic.field("list_empty", dynamic.list(dynamic.int)),
      dynamic.field("list_empty_end", dynamic.list(dynamic.int)),
      dynamic.field("list_empty_negative", dynamic.list(dynamic.int)),
      dynamic.field("list_nested", dynamic.list(dynamic.list(dynamic.string))),
    )
  let #(_, list_test) = should.be_ok(nbeet.decode(nbt, decoder))
  should.equal(list_test.value, [42])
  should.equal(list_test.empty, [])
  // List with an END type id
  should.equal(list_test.empty_end, [])
  // List with a negative length
  should.equal(list_test.empty_negative, [])
  should.equal(list_test.nested, [["egg"]])
}

pub type ValueCompoundTest {
  ValueCompoundTest(value: Int)
}

pub type NestedCompoundTest {
  NestedCompoundTest(nest: String)
}

pub type NesterCompoundTest {
  NesterCompoundTest(nested: NestedCompoundTest)
}

pub type CompoundTest {
  CompoundTest(
    value: ValueCompoundTest,
    empty: dict.Dict(String, Int),
    nester: NesterCompoundTest,
  )
}

pub fn decode_compound_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/compound_test.nbt")
  let value_compound_decoder =
    dynamic.decode1(ValueCompoundTest, dynamic.field("", dynamic.int))
  let nested_compound_decoder =
    dynamic.decode1(NestedCompoundTest, dynamic.field("nest", dynamic.string))
  let nester_compound_decoder =
    dynamic.decode1(
      NesterCompoundTest,
      dynamic.field("compound_nested", nested_compound_decoder),
    )
  let decoder =
    dynamic.decode3(
      CompoundTest,
      dynamic.field("compound", value_compound_decoder),
      dynamic.field("compound_empty", dynamic.dict(dynamic.string, dynamic.int)),
      dynamic.field("compound_nester", nester_compound_decoder),
    )
  let #(_, compound_test) = should.be_ok(nbeet.decode(nbt, decoder))
  should.equal(compound_test.value.value, 42)
  should.equal(dict.size(compound_test.empty), 0)
  should.equal(compound_test.nester.nested.nest, "egg")
}

pub fn decode_int_array_test() {
  todo
}

pub fn decode_long_array_test() {
  todo
}
