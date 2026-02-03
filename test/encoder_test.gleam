import gleam/bit_array
import nbeet/nbt
import simplifile

fn assert_bit_arrays(actual: BitArray, expected: BitArray) {
  assert bit_array.inspect(actual) == bit_array.inspect(expected)
}

const empty_java_nbt = <<0x0A, 0x00, 0x00, 0x00>>

pub fn encode_empty_java_test() {
  let nbt = nbt.root([])
  let encoded_nbt = nbt.java_encode(nbt, "")
  assert_bit_arrays(encoded_nbt, empty_java_nbt)
}

const empty_java_network_nbt = <<0x0A, 0x00>>

pub fn encode_empty_java_network_test() {
  let nbt = nbt.root([])
  let encoded_nbt = nbt.java_network_encode(nbt)
  assert_bit_arrays(encoded_nbt, empty_java_network_nbt)
}

pub type IntegerTest {
  IntegerTest(value: Int, zero: Int, min: Int, max: Int)
}

fn integer_test_encoder(
  integer_test: IntegerTest,
  prefix: String,
  using: fn(Int) -> nbt.Tag,
) {
  nbt.root([
    #(prefix, using(integer_test.value)),
    #(prefix <> "_zero", using(integer_test.zero)),
    #(prefix <> "_min", using(integer_test.min)),
    #(prefix <> "_max", using(integer_test.max)),
  ])
}

pub fn encode_byte_test() {
  let assert Ok(expected) = simplifile.read_bits("test/nbt/byte_test.nbt")
  let nbt =
    integer_test_encoder(IntegerTest(42, 0, -128, 127), "byte", nbt.byte)
  let actual = nbt.java_encode(nbt, "")
  assert_bit_arrays(actual, expected)
}

pub fn encode_short_test() {
  let assert Ok(expected) = simplifile.read_bits("test/nbt/short_test.nbt")
  let nbt =
    integer_test_encoder(
      IntegerTest(42, 0, -32_768, 32_767),
      "short",
      nbt.short,
    )
  let actual = nbt.java_encode(nbt, "")
  assert_bit_arrays(actual, expected)
}

pub fn encode_int_test() {
  let assert Ok(expected) = simplifile.read_bits("test/nbt/int_test.nbt")
  let nbt =
    integer_test_encoder(
      IntegerTest(42, 0, -2_147_483_648, 2_147_483_647),
      "int",
      nbt.int,
    )
  let actual = nbt.java_encode(nbt, "")
  assert_bit_arrays(actual, expected)
}

pub fn encode_long_test() {
  let assert Ok(expected) = simplifile.read_bits("test/nbt/long_test.nbt")
  let nbt =
    integer_test_encoder(
      IntegerTest(42, 0, -9_223_372_036_854_775_808, 9_223_372_036_854_775_807),
      "long",
      nbt.long,
    )
  let actual = nbt.java_encode(nbt, "")
  assert_bit_arrays(actual, expected)
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

fn decimal_test_encoder(
  decimal_test: DecimalTest,
  prefix: String,
  using: fn(Float) -> nbt.Tag,
) {
  nbt.root([
    #(prefix, using(decimal_test.value)),
    #(prefix <> "_zero", using(decimal_test.zero)),
    #(prefix <> "_min", using(decimal_test.min)),
    #(prefix <> "_max", using(decimal_test.max)),
    #(prefix <> "_infinitesimal", using(decimal_test.infinitesimal)),
  ])
}

pub fn encode_float_test() {
  let assert Ok(expected) = simplifile.read_bits("test/nbt/float_test.nbt")
  let nbt =
    decimal_test_encoder(
      DecimalTest(
        42.0,
        0.0,
        -3.4028234663852886e38,
        3.4028234663852886e38,
        1.401298464324817e-45,
      ),
      "float",
      nbt.float,
    )
  let actual = nbt.java_encode(nbt, "")
  assert_bit_arrays(actual, expected)
}

pub fn encode_double_test() {
  let assert Ok(expected) = simplifile.read_bits("test/nbt/double_test.nbt")
  let nbt =
    decimal_test_encoder(
      DecimalTest(
        42.0,
        0.0,
        -1.7976931348623157e308,
        1.7976931348623157e308,
        4.9406564584124654e-324,
      ),
      "double",
      nbt.double,
    )
  let actual = nbt.java_encode(nbt, "")
  assert_bit_arrays(actual, expected)
}

pub type ByteArrayTest {
  ByteArrayTest(value: BitArray, empty: BitArray, min: BitArray, max: BitArray)
}

fn byte_array_test_encoder(byte_array_test: ByteArrayTest) {
  nbt.root([
    #("byte_array", nbt.byte_array(byte_array_test.value)),
    #("byte_array_empty", nbt.byte_array(byte_array_test.empty)),
    #("byte_array_min", nbt.byte_array(byte_array_test.min)),
    #("byte_array_max", nbt.byte_array(byte_array_test.max)),
  ])
}

pub fn encode_byte_array_test() {
  let assert Ok(expected) = simplifile.read_bits("test/nbt/byte_array_test.nbt")
  let nbt = byte_array_test_encoder(ByteArrayTest(<<42>>, <<>>, <<0>>, <<255>>))
  let actual = nbt.java_encode(nbt, "")
  assert_bit_arrays(actual, expected)
}

pub type StringTest {
  StringTest(value: String, empty: String, emoji: String)
}

fn string_test_encoder(string_test: StringTest) {
  nbt.root([
    #("string", nbt.string(string_test.value)),
    #("string_empty", nbt.string(string_test.empty)),
    #("string_emoji", nbt.string(string_test.emoji)),
  ])
}

pub fn encode_string_test() {
  let assert Ok(expected) = simplifile.read_bits("test/nbt/string_test.nbt")
  let nbt = string_test_encoder(StringTest("42", "", "⭐"))
  let actual = nbt.java_encode(nbt, "")
  assert_bit_arrays(actual, expected)
}

pub type ListTest {
  ListTest(value: List(Int), empty: List(Int), nested: List(List(String)))
}

fn list_test_encoder(list_test: ListTest) {
  nbt.root([
    #("list", nbt.list(nbt.byte, list_test.value)),
    #("list_empty", nbt.list(nbt.byte, list_test.empty)),
    #("list_nested", nbt.list(nbt.list(nbt.string, _), list_test.nested)),
  ])
}

pub fn encode_list_test() {
  let assert Ok(expected) =
    simplifile.read_bits("test/nbt/list_encode_test.nbt")
  let nbt = list_test_encoder(ListTest([42], [], [["egg"]]))
  let actual = nbt.java_encode(nbt, "")
  assert_bit_arrays(actual, expected)
}

fn compound_test_encoder() {
  nbt.root([
    #("compound", nbt.compound([#("", nbt.byte(42))])),
    #("compound_empty", nbt.compound([])),
    #(
      "compound_nester",
      nbt.compound([
        #("compound_nested", nbt.compound([#("nest", nbt.string("egg"))])),
      ]),
    ),
  ])
}

pub fn encode_compound_test() {
  let assert Ok(expected) = simplifile.read_bits("test/nbt/compound_test.nbt")
  let nbt = compound_test_encoder()
  let actual = nbt.java_encode(nbt, "")
  assert_bit_arrays(actual, expected)
}

pub type ArrayTest {
  ArrayTest(value: List(Int), empty: List(Int))
}

fn array_test_encoder(
  array_test: ArrayTest,
  prefix: String,
  using: fn(List(Int)) -> nbt.Tag,
) {
  nbt.root([
    #(prefix <> "_array", using(array_test.value)),
    #(prefix <> "_array_empty", using(array_test.empty)),
  ])
}

pub fn encode_int_array_test() {
  let assert Ok(expected) = simplifile.read_bits("test/nbt/int_array_test.nbt")
  let nbt = array_test_encoder(ArrayTest([42], []), "int", nbt.int_array)
  let actual = nbt.java_encode(nbt, "")
  assert_bit_arrays(actual, expected)
}

pub fn encode_long_array_test() {
  let assert Ok(expected) = simplifile.read_bits("test/nbt/long_array_test.nbt")
  let nbt = array_test_encoder(ArrayTest([42], []), "long", nbt.long_array)
  let actual = nbt.java_encode(nbt, "")
  assert_bit_arrays(actual, expected)
}
