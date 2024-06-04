import gleam/dict
import gleam/dynamic
import gleam/list
import nbeet/internal/decoder
import nbeet/internal/encoder
import nbeet/internal/nbt.{type Nbt, Nbt}
import nbeet/internal/tag.{type Tag}

pub fn nbt(name: String, tag: Tag) {
  Nbt(name, tag)
}

pub fn byte(byte: BitArray) -> Tag {
  tag.Byte(byte)
}

pub fn boolean(boolean: Bool) -> Tag {
  case boolean {
    True -> tag.Byte(<<1>>)
    False -> tag.Byte(<<0>>)
  }
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
  tag.Compound(dict.from_list(compound))
}

pub fn int_array(int_array: List(Int)) -> Tag {
  tag.IntArray(int_array)
}

pub fn long_array(long_array: List(Int)) -> Tag {
  tag.LongArray(long_array)
}

pub fn encode(nbt: Nbt) {
  encoder.encode(nbt)
}

pub fn decode(bit_array: BitArray, decoder: dynamic.Decoder(t)) {
  decoder.decode(bit_array, decoder)
}
