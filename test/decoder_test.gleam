import decode/zero
import gleam/dict
import gleeunit/should
import nbeet
import simplifile

pub type IntegerTest {
  IntegerTest(value: Int, zero: Int, min: Int, max: Int)
}

fn integer_test_decoder(field_prefix: String) {
  use value <- zero.field(field_prefix, zero.int)
  use zero <- zero.field(field_prefix <> "_zero", zero.int)
  use min <- zero.field(field_prefix <> "_min", zero.int)
  use max <- zero.field(field_prefix <> "_max", zero.int)
  zero.success(IntegerTest(value, zero, min, max))
}

pub fn updated_decode_byte_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/byte_test.nbt")
  let decoder = integer_test_decoder("byte")
  let #(_, byte_test) = should.be_ok(nbeet.java_decode(nbt, decoder))
  should.equal(byte_test.value, 42)
  should.equal(byte_test.zero, 0)
  should.equal(byte_test.min, -128)
  should.equal(byte_test.max, 127)
}

pub fn decode_short_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/short_test.nbt")
  let decoder = integer_test_decoder("short")
  let #(_, short_test) = should.be_ok(nbeet.java_decode(nbt, decoder))
  should.equal(short_test.value, 42)
  should.equal(short_test.zero, 0)
  should.equal(short_test.min, -32_768)
  should.equal(short_test.max, 32_767)
}

pub fn decode_int_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/int_test.nbt")
  let decoder = integer_test_decoder("int")
  let #(_, int_test) = should.be_ok(nbeet.java_decode(nbt, decoder))
  should.equal(int_test.value, 42)
  should.equal(int_test.zero, 0)
  should.equal(int_test.min, -2_147_483_648)
  should.equal(int_test.max, 2_147_483_647)
}

pub fn decode_long_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/long_test.nbt")
  let decoder = integer_test_decoder("long")
  let #(_, long_test) = should.be_ok(nbeet.java_decode(nbt, decoder))
  should.equal(long_test.value, 42)
  should.equal(long_test.zero, 0)
  should.equal(long_test.min, -9_223_372_036_854_775_808)
  should.equal(long_test.max, 9_223_372_036_854_775_807)
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
  use value <- zero.field(field_prefix, zero.float)
  use zero <- zero.field(field_prefix <> "_zero", zero.float)
  use min <- zero.field(field_prefix <> "_min", zero.float)
  use max <- zero.field(field_prefix <> "_max", zero.float)
  use infinitesimal <- zero.field(field_prefix <> "_infinitesimal", zero.float)
  zero.success(DecimalTest(value, zero, min, max, infinitesimal))
}

pub fn decode_float_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/float_test.nbt")
  let decoder = decimal_test_decoder("float")
  let #(_, float_test) = should.be_ok(nbeet.java_decode(nbt, decoder))
  should.equal(float_test.value, 42.0)
  should.equal(float_test.zero, 0.0)
  should.equal(float_test.min, -3.4028234663852886e38)
  should.equal(float_test.max, 3.4028234663852886e38)
  should.equal(float_test.infinitesimal, 1.401298464324817e-45)
}

pub fn decode_double_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/double_test.nbt")
  let decoder = decimal_test_decoder("double")
  let #(_, double_test) = should.be_ok(nbeet.java_decode(nbt, decoder))
  should.equal(double_test.value, 42.0)
  should.equal(double_test.zero, 0.0)
  should.equal(double_test.min, -1.7976931348623157e308)
  should.equal(double_test.max, 1.7976931348623157e308)
  should.equal(double_test.infinitesimal, 4.9406564584124654e-324)
}

pub type ByteArrayTest {
  ByteArrayTest(value: BitArray, empty: BitArray, min: BitArray, max: BitArray)
}

fn byte_array_test_decoder() {
  use value <- zero.field("byte_array", zero.bit_array)
  use empty <- zero.field("byte_array_empty", zero.bit_array)
  use min <- zero.field("byte_array_min", zero.bit_array)
  use max <- zero.field("byte_array_max", zero.bit_array)
  zero.success(ByteArrayTest(value, empty, min, max))
}

pub fn decode_byte_array_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/byte_array_test.nbt")
  let decoder = byte_array_test_decoder()
  let #(_, byte_array_test) = should.be_ok(nbeet.java_decode(nbt, decoder))
  should.equal(byte_array_test.value, <<42>>)
  should.equal(byte_array_test.empty, <<>>)
  should.equal(byte_array_test.min, <<0>>)
  should.equal(byte_array_test.max, <<255>>)
}

pub type StringTest {
  StringTest(value: String, empty: String, emoji: String)
}

fn string_test_decoder() {
  use value <- zero.field("string", zero.string)
  use empty <- zero.field("string_empty", zero.string)
  use emoji <- zero.field("string_emoji", zero.string)
  zero.success(StringTest(value, empty, emoji))
}

pub fn decode_string_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/string_test.nbt")
  let decoder = string_test_decoder()
  let #(_, string_test) = should.be_ok(nbeet.java_decode(nbt, decoder))
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

fn list_test_decoder() {
  use value <- zero.field("list", zero.list(zero.int))
  use empty <- zero.field("list_empty", zero.list(zero.int))
  use empty_end <- zero.field("list_empty_end", zero.list(zero.int))
  use empty_negative <- zero.field("list_empty_negative", zero.list(zero.int))
  use nested <- zero.field("list_nested", zero.list(zero.list(zero.string)))
  zero.success(ListTest(value, empty, empty_end, empty_negative, nested))
}

pub fn decode_list_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/list_test.nbt")
  let decoder = list_test_decoder()
  let #(_, list_test) = should.be_ok(nbeet.java_decode(nbt, decoder))
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

fn value_compound_test_decoder() {
  use value <- zero.field("", zero.int)
  zero.success(ValueCompoundTest(value))
}

pub type NestedCompoundTest {
  NestedCompoundTest(nest: String)
}

fn nested_compound_test_decoder() {
  use nest <- zero.field("nest", zero.string)
  zero.success(NestedCompoundTest(nest))
}

pub type NesterCompoundTest {
  NesterCompoundTest(nested: NestedCompoundTest)
}

fn nester_compound_test_decoder() {
  use compound_nested <- zero.field(
    "compound_nested",
    nested_compound_test_decoder(),
  )
  zero.success(NesterCompoundTest(compound_nested))
}

pub type CompoundTest {
  CompoundTest(
    value: ValueCompoundTest,
    empty: dict.Dict(String, Int),
    nester: NesterCompoundTest,
  )
}

fn compound_test_decoder() {
  use compound <- zero.field("compound", value_compound_test_decoder())
  use compound_empty <- zero.field(
    "compound_empty",
    zero.dict(zero.string, zero.int),
  )
  use compound_nester <- zero.field(
    "compound_nester",
    nester_compound_test_decoder(),
  )
  zero.success(CompoundTest(compound, compound_empty, compound_nester))
}

pub fn decode_compound_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/compound_test.nbt")
  let decoder = compound_test_decoder()
  let #(_, compound_test) = should.be_ok(nbeet.java_decode(nbt, decoder))
  should.equal(compound_test.value.value, 42)
  should.equal(dict.size(compound_test.empty), 0)
  should.equal(compound_test.nester.nested.nest, "egg")
}

pub type ArrayTest {
  ArrayTest(value: List(Int), empty: List(Int))
}

fn array_test_decoder(field_prefix: String) {
  use array <- zero.field(field_prefix <> "_array", zero.list(zero.int))
  use empty <- zero.field(field_prefix <> "_array_empty", zero.list(zero.int))
  zero.success(ArrayTest(array, empty))
}

pub fn decode_int_array_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/int_array_test.nbt")
  let decoder = array_test_decoder("int")
  let #(_, int_array_test) = should.be_ok(nbeet.java_decode(nbt, decoder))
  should.equal(int_array_test.value, [42])
  should.equal(int_array_test.empty, [])
}

pub fn decode_long_array_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/long_array_test.nbt")
  let decoder = array_test_decoder("long")
  let #(_, long_array_test) = should.be_ok(nbeet.java_decode(nbt, decoder))
  should.equal(long_array_test.value, [42])
  should.equal(long_array_test.empty, [])
}
