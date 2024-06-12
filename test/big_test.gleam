import gleam/dynamic
import gleam/float
import gleam/iterator
import gleam/list
import gleeunit/should
import nbeet
import simplifile

pub type NestedCompound {
  NestedCompound(name: String, value: Float)
}

pub type NestedCompounds {
  NestedCompounds(egg: NestedCompound, ham: NestedCompound)
}

pub type CompoundListItem {
  CompoundListItem(created_on: Int, name: String)
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

pub fn big_test() {
  let assert Ok(nbt) =
    simplifile.read_bits("test/nbt/big_test/uncompressed.nbt")

  let compound_list_item_decoder =
    dynamic.decode2(
      CompoundListItem,
      dynamic.field("created-on", dynamic.int),
      dynamic.field("name", dynamic.string),
    )

  let nested_compound_decoder =
    dynamic.decode2(
      NestedCompound,
      dynamic.field("name", dynamic.string),
      dynamic.field("value", dynamic.float),
    )

  let nested_compounds_decoder =
    dynamic.decode2(
      NestedCompounds,
      dynamic.field("egg", nested_compound_decoder),
      dynamic.field("ham", nested_compound_decoder),
    )

  let decoder =
    decode11(
      BigTest,
      dynamic.field("byteTest", dynamic.int),
      dynamic.field("shortTest", dynamic.int),
      dynamic.field("intTest", dynamic.int),
      dynamic.field("longTest", dynamic.int),
      dynamic.field("floatTest", dynamic.float),
      dynamic.field("doubleTest", dynamic.float),
      dynamic.field(
        "byteArrayTest (the first 1000 values of (n*n*255+n*7)%100, starting with n=0 (0, 62, 34, 16, 8, ...))",
        dynamic.bit_array,
      ),
      dynamic.field("stringTest", dynamic.string),
      dynamic.field("listTest (long)", dynamic.list(dynamic.int)),
      dynamic.field(
        "listTest (compound)",
        dynamic.list(compound_list_item_decoder),
      ),
      dynamic.field("nested compound test", nested_compounds_decoder),
    )
  let #(_, big_test) = should.be_ok(nbeet.decode(nbt, decoder))

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

pub fn decode11(
  constructor: fn(t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11) -> t,
  t1: dynamic.Decoder(t1),
  t2: dynamic.Decoder(t2),
  t3: dynamic.Decoder(t3),
  t4: dynamic.Decoder(t4),
  t5: dynamic.Decoder(t5),
  t6: dynamic.Decoder(t6),
  t7: dynamic.Decoder(t7),
  t8: dynamic.Decoder(t8),
  t9: dynamic.Decoder(t9),
  t10: dynamic.Decoder(t10),
  t11: dynamic.Decoder(t11),
) -> dynamic.Decoder(t) {
  fn(x: dynamic.Dynamic) {
    case
      t1(x),
      t2(x),
      t3(x),
      t4(x),
      t5(x),
      t6(x),
      t7(x),
      t8(x),
      t9(x),
      t10(x),
      t11(x)
    {
      Ok(a),
        Ok(b),
        Ok(c),
        Ok(d),
        Ok(e),
        Ok(f),
        Ok(g),
        Ok(h),
        Ok(i),
        Ok(j),
        Ok(k)
      -> Ok(constructor(a, b, c, d, e, f, g, h, i, j, k))
      a, b, c, d, e, f, g, h, i, j, k ->
        Error(
          list.concat([
            all_errors(a),
            all_errors(b),
            all_errors(c),
            all_errors(d),
            all_errors(e),
            all_errors(f),
            all_errors(g),
            all_errors(h),
            all_errors(i),
            all_errors(j),
            all_errors(k),
          ]),
        )
    }
  }
}

fn all_errors(
  result: Result(a, List(dynamic.DecodeError)),
) -> List(dynamic.DecodeError) {
  case result {
    Ok(_) -> []
    Error(errors) -> errors
  }
}
