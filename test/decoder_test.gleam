import gleam/bit_array
import gleam/dynamic
import gleam/io
import gleeunit/should
import nbeet
import simplifile

// const hello_world_nbt = <<
//   0x0A, 0x00, 0x0B, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C,
//   0x64, 0x08, 0x00, 0x04, 0x6E, 0x61, 0x6D, 0x65, 0x00, 0x09, 0x42, 0x61, 0x6E,
//   0x61, 0x6E, 0x72, 0x61, 0x6D, 0x61, 0x00,
// >>

// pub type HelloWorld {
//   HelloWorld(name: String)
// }

// pub fn decode_hello_world_test() {
//   let decoder =
//     dynamic.decode1(HelloWorld, dynamic.field("name", dynamic.string))
//   let #(name, hello_world) =
//     should.be_ok(nbeet.decode(hello_world_nbt, decoder))
//   should.equal(name, "hello world")
//   should.equal(hello_world.name, "Bananrama")
// }

// const byte_test_nbt = <<
//   0x0A, 0x00, 0x00, 0x01, 0x00, 0x01, 0x61, 0x7F, 0x01, 0x00, 0x01, 0x62, 0x7F,
//   0x00,
// >>

pub type ByteTest {
  ByteTest(byte: BitArray, min: BitArray, max: BitArray)
}

pub fn decode_byte_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/byte_test.nbt")
  let decoder =
    dynamic.decode3(
      ByteTest,
      dynamic.field("byte", dynamic.bit_array),
      dynamic.field("byte_min", dynamic.bit_array),
      dynamic.field("byte_max", dynamic.bit_array),
    )
  let #(_, byte_test) = should.be_ok(nbeet.decode(nbt, decoder))
  io.debug(byte_test)
  should.equal(byte_test.byte, <<0>>)
  should.equal(byte_test.byte, <<0>>)
  should.equal(byte_test.min, <<128>>)
  should.equal(byte_test.max, <<127>>)
}

pub type ShortTest {
  ShortTest(short: Int, min: Int, max: Int)
}

pub fn decode_short_test() {
  let assert Ok(nbt) = simplifile.read_bits("test/nbt/short_test.nbt")
  let decoder =
    dynamic.decode3(
      ShortTest,
      dynamic.field("short", dynamic.int),
      dynamic.field("short_min", dynamic.int),
      dynamic.field("short_max", dynamic.int),
    )
  let #(_, short_test) = should.be_ok(nbeet.decode(nbt, decoder))
  should.equal(short_test.short, 1)
  should.equal(short_test.min, -32_767)
  should.equal(short_test.max, 32_767)
}
