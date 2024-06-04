import gleam/dynamic
import gleeunit/should
import nbeet

const hello_world_nbt = <<
  0x0A, 0x00, 0x0B, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C,
  0x64, 0x08, 0x00, 0x04, 0x6E, 0x61, 0x6D, 0x65, 0x00, 0x09, 0x42, 0x61, 0x6E,
  0x61, 0x6E, 0x72, 0x61, 0x6D, 0x61, 0x00,
>>

pub type HelloWorld {
  HelloWorld(name: String)
}

pub fn decode_hello_world_test() {
  let decoder =
    dynamic.decode1(HelloWorld, dynamic.field("name", dynamic.string))
  let #(name, hello_world) =
    should.be_ok(nbeet.decode(hello_world_nbt, decoder))
  should.equal(name, "hello world")
  should.equal(hello_world.name, "Bananrama")
}

const byte_test_nbt = <<
  0x0A, 0x00, 0x00, 0x01, 0x00, 0x01, 0x61, 0x7F, 0x01, 0x00, 0x01, 0x62, 0x7F,
  0x00,
>>

pub type ByteTest {
  ByteTest(a: BitArray, b: BitArray)
}

pub fn decode_byte_test() {
  let decoder =
    dynamic.decode2(
      ByteTest,
      dynamic.field("a", dynamic.bit_array),
      dynamic.field("b", dynamic.bit_array),
    )
  let #(name, byte_test) = should.be_ok(nbeet.decode(byte_test_nbt, decoder))
  should.equal(name, "")
  should.equal(byte_test.a, <<127>>)
  should.equal(byte_test.b, <<127>>)
}
