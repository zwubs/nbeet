import gleam/dynamic/decode
import gleam/list
import gleam/option.{None, Some}
import nbeet/internal/decoder
import nbeet/internal/encoder
import nbeet/internal/tag

pub opaque type Nbt {
  Nbt(tag: Tag)
}

pub type Tag =
  tag.Tag

pub const empty = Nbt(tag.Compound([]))

pub fn root(root: List(#(String, Tag))) {
  Nbt(compound(root))
}

pub fn byte(byte: Int) -> Tag {
  tag.Byte(byte)
}

pub fn short(short: Int) -> Tag {
  tag.Short(short)
}

pub fn int(int: Int) -> Tag {
  tag.Int(int)
}

pub fn long(long: Int) -> Tag {
  tag.Long(long)
}

pub fn float(float: Float) -> Tag {
  tag.Float(float)
}

pub fn double(double: Float) -> Tag {
  tag.Double(double)
}

pub fn byte_array(byte_array: BitArray) -> Tag {
  tag.ByteArray(byte_array)
}

pub fn string(string: String) -> Tag {
  tag.String(string)
}

pub fn list(tag: fn(value) -> Tag, list: List(value)) {
  tag.List(list.map(list, tag))
}

pub fn compound(compound: List(#(String, Tag))) -> Tag {
  tag.Compound(compound)
}

pub fn int_array(int_array: List(Int)) -> Tag {
  tag.IntArray(int_array)
}

pub fn long_array(long_array: List(Int)) -> Tag {
  tag.LongArray(long_array)
}

pub fn java_encode(nbt: Nbt, root_name: String) {
  encoder.encode(nbt.tag, Some(root_name))
}

pub fn java_network_encode(nbt: Nbt) {
  encoder.encode(nbt.tag, None)
}

pub fn java_decode(bit_array: BitArray, decoder: decode.Decoder(t)) {
  decoder.java_decode(bit_array, decoder)
}

pub fn java_network_decode(bit_array: BitArray, decoder: decode.Decoder(t)) {
  decoder.java_network_decode(bit_array, decoder)
}
