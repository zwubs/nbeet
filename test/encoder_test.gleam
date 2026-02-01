import gleam/bit_array
import gleeunit/should
import nbeet/nbt

fn assert_bit_arrays(a: BitArray, b: BitArray) {
  assert bit_array.inspect(a) == bit_array.inspect(b)
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

const hello_world_nbt = <<
  0x0A, 0x00, 0x0B, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C,
  0x64, 0x08, 0x00, 0x04, 0x6E, 0x61, 0x6D, 0x65, 0x00, 0x09, 0x42, 0x61, 0x6E,
  0x61, 0x6E, 0x72, 0x61, 0x6D, 0x61, 0x00,
>>

pub fn encode_hello_world_test() {
  let nbt = nbt.root([#("name", nbt.string("Bananrama"))])
  let encoded_nbt = nbt.java_encode(nbt, "hello world")
  assert_bit_arrays(encoded_nbt, hello_world_nbt)
}

const byte_test_nbt = <<
  0x0A, 0x00, 0x00, 0x01, 0x00, 0x01, 0x61, 0x7F, 0x01, 0x00, 0x01, 0x62, 0x7F,
  0x00,
>>

pub fn encode_byte_test() {
  let nbt = nbt.root([#("a", nbt.byte(127)), #("b", nbt.byte(127))])
  let encoded_nbt = nbt.java_encode(nbt, "")
  should.equal(bit_array.inspect(encoded_nbt), bit_array.inspect(byte_test_nbt))
}
// const short_test_nbt = <<
//   0x0A, 0x00, 0x00, 0x02, 0x00, 0x01, 0x61, 0x7F, 0x01, 0x00, 0x01, 0x62, 0x7F,
//   0x00,
// >>

// pub fn encode_short_test() {
//   let nbt = nbt("", compound([#("a", short(1)), #("b", short(32_767))]))
//   use encoded_nbt <- result.try(nbt.encode(nbt))
//   should.equal(
//     bit_array.inspect(encoded_nbt),
//     bit_array.inspect(short_test_nbt),
//   )
//   Ok(Nil)
// }
