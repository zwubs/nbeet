import gleam/bit_array
import gleam/result
import gleeunit/should
import nbeet.{byte, compound, nbt, short, string}

const hello_world_nbt = <<
  0x0A, 0x00, 0x0B, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x77, 0x6F, 0x72, 0x6C,
  0x64, 0x08, 0x00, 0x04, 0x6E, 0x61, 0x6D, 0x65, 0x00, 0x09, 0x42, 0x61, 0x6E,
  0x61, 0x6E, 0x72, 0x61, 0x6D, 0x61, 0x00,
>>

pub fn encode_hello_world_test() {
  let nbt = nbt("hello world", compound([#("name", string("Bananrama"))]))
  use encoded_nbt <- result.try(nbeet.encode(nbt))
  should.equal(
    bit_array.inspect(encoded_nbt),
    bit_array.inspect(hello_world_nbt),
  )
  Ok(Nil)
}

const byte_test_nbt = <<
  0x0A, 0x00, 0x00, 0x01, 0x00, 0x01, 0x61, 0x7F, 0x01, 0x00, 0x01, 0x62, 0x7F,
  0x00,
>>

pub fn encode_byte_test() {
  let nbt = nbt("", compound([#("a", byte(127)), #("b", byte(127))]))
  use encoded_nbt <- result.try(nbeet.encode(nbt))
  should.equal(bit_array.inspect(encoded_nbt), bit_array.inspect(byte_test_nbt))
  Ok(Nil)
}
// const short_test_nbt = <<
//   0x0A, 0x00, 0x00, 0x02, 0x00, 0x01, 0x61, 0x7F, 0x01, 0x00, 0x01, 0x62, 0x7F,
//   0x00,
// >>

// pub fn encode_short_test() {
//   let nbt = nbt("", compound([#("a", short(1)), #("b", short(32_767))]))
//   use encoded_nbt <- result.try(nbeet.encode(nbt))
//   should.equal(
//     bit_array.inspect(encoded_nbt),
//     bit_array.inspect(short_test_nbt),
//   )
//   Ok(Nil)
// }
