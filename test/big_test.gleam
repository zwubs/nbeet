import decode/zero
import gleam/float
import gleam/iterator
import gleeunit/should
import nbeet
import simplifile

pub type NestedCompound {
  NestedCompound(name: String, value: Float)
}

fn nested_compound_decoder() {
  use name <- zero.field("name", zero.string)
  use value <- zero.field("value", zero.float)
  zero.success(NestedCompound(name, value))
}

pub type NestedCompounds {
  NestedCompounds(egg: NestedCompound, ham: NestedCompound)
}

fn nested_compounds_decoder() {
  use egg <- zero.field("egg", nested_compound_decoder())
  use ham <- zero.field("ham", nested_compound_decoder())
  zero.success(NestedCompounds(egg, ham))
}

pub type CompoundListItem {
  CompoundListItem(created_on: Int, name: String)
}

fn compound_list_item_decoder() {
  use created_on <- zero.field("created-on", zero.int)
  use name <- zero.field("name", zero.string)
  zero.success(CompoundListItem(created_on, name))
}

pub type BigTest {
  BigTest(
    byte_test: Int,
    short_test: Int,
    int_test: Int,
    long_test: Int,
    float_test: Float,
    double_test: Float,
    byte_array_test: BitArray,
    string_test: String,
    list_test: List(Int),
    compound_list_test: List(CompoundListItem),
    nested_compound_test: NestedCompounds,
  )
}

fn big_test_decoder() {
  use byte_test <- zero.field("byteTest", zero.int)
  use short_test <- zero.field("shortTest", zero.int)
  use int_test <- zero.field("intTest", zero.int)
  use long_test <- zero.field("longTest", zero.int)
  use float_test <- zero.field("floatTest", zero.float)
  use double_test <- zero.field("doubleTest", zero.float)
  use byte_array_test <- zero.field(
    "byteArrayTest (the first 1000 values of (n*n*255+n*7)%100, starting with n=0 (0, 62, 34, 16, 8, ...))",
    zero.bit_array,
  )
  use string_test <- zero.field("stringTest", zero.string)
  use list_test <- zero.field("listTest (long)", zero.list(zero.int))
  use compound_list_test <- zero.field(
    "listTest (compound)",
    zero.list(compound_list_item_decoder()),
  )
  use nested_compound_test <- zero.field(
    "nested compound test",
    nested_compounds_decoder(),
  )
  zero.success(BigTest(
    byte_test,
    short_test,
    int_test,
    long_test,
    float_test,
    double_test,
    byte_array_test,
    string_test,
    list_test,
    compound_list_test,
    nested_compound_test,
  ))
}

pub fn big_test() {
  let assert Ok(nbt) =
    simplifile.read_bits("test/nbt/big_test/uncompressed.nbt")
  let #(_, big_test) = should.be_ok(nbeet.java_decode(nbt, big_test_decoder()))

  should.equal(big_test.byte_test, 127)
  should.equal(big_test.short_test, 32_767)
  should.equal(big_test.int_test, 2_147_483_647)
  should.equal(big_test.long_test, 9_223_372_036_854_775_807)
  should.be_true(float.loosely_equals(
    big_test.float_test,
    0.49823147,
    0.00000001,
  ))
  should.equal(big_test.double_test, 0.4931287132182315)
  let expected_byte_array =
    iterator.range(from: 0, to: 999)
    |> iterator.map(fn(i) { { i * i * 255 + i * 7 } % 100 })
    |> iterator.fold(<<>>, fn(bit_array, int) { <<bit_array:bits, int:int>> })
  should.equal(big_test.byte_array_test, expected_byte_array)
  should.equal(big_test.list_test, [11, 12, 13, 14, 15])
  let expected_compound_list = [
    CompoundListItem(1_264_099_775_885, "Compound tag #0"),
    CompoundListItem(1_264_099_775_885, "Compound tag #1"),
  ]
  should.equal(big_test.compound_list_test, expected_compound_list)
  let expected_nested_compound =
    NestedCompounds(
      egg: NestedCompound("Eggbert", 0.5),
      ham: NestedCompound("Hampus", 0.75),
    )
  should.equal(big_test.nested_compound_test, expected_nested_compound)
}
