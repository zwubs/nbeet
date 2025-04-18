import gleam/bit_array
import gleam/bytes_tree
import gleam/dict
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import nbeet/internal/tag.{type Tag}
import nbeet/internal/type_id

pub fn encode(root_tag: Tag, root_name: Option(String)) {
  case root_tag {
    tag.Compound(compound) -> {
      let name = case root_name {
        Some(name) -> encode_string(name)
        None -> <<>>
      }
      let encoded_compound = encode_compound(compound)
      Ok(<<type_id.compound:int, name:bits, encoded_compound:bits>>)
    }
    _ -> Error(Nil)
  }
}

fn encode_tag(tag: Tag) {
  case tag {
    tag.End -> <<>>
    tag.Byte(byte) -> encode_byte(byte)
    tag.Short(short) -> encode_short(short)
    tag.Int(int) -> encode_int(int)
    tag.Long(long) -> encode_long(long)
    tag.Float(float) -> encode_float(float)
    tag.Double(double) -> encode_double(double)
    tag.ByteArray(byte_array) -> encode_byte_array(byte_array)
    tag.String(string) -> encode_string(string)
    tag.List(list) -> encode_list(list)
    tag.Compound(compound) -> encode_compound(compound)
    tag.IntArray(int_array) -> encode_int_array(int_array)
    tag.LongArray(long_array) -> encode_long_array(long_array)
  }
}

fn encode_byte(byte: Int) {
  <<byte:int-big-size(8)>>
}

fn encode_short(short: Int) {
  <<short:int-big-size(16)>>
}

fn encode_int(int: Int) {
  <<int:int-big-size(32)>>
}

fn encode_long(long: Int) {
  <<long:int-big-size(64)>>
}

fn encode_float(float: Float) {
  <<float:float-big-size(32)>>
}

fn encode_double(double: Float) {
  <<double:float-big-size(64)>>
}

fn encode_byte_array(byte_array: BitArray) {
  let length = bit_array.byte_size(byte_array)
  <<length:int-big-size(32), byte_array:bits>>
}

fn encode_string(string: String) {
  let length = string.length(string)
  <<length:int-big-size(16), string:utf8>>
}

fn encode_list(list: List(Tag)) {
  case list {
    [first_tag, ..] -> {
      let type_id = type_id.from_tag(first_tag)
      let length = list.length(list)
      let encoded_tags =
        list.fold(list, <<>>, fn(bit_array, tag) {
          bit_array.append(bit_array, encode_tag(tag))
        })
      <<type_id:int, length:size(32), encoded_tags:bits, type_id.end:int>>
    }
    _ -> <<type_id.end:int, 0:size(32)>>
  }
}

fn encode_compound(compound: List(#(String, Tag))) {
  compound
  |> dict.from_list
  |> dict.to_list
  |> list.fold(bytes_tree.new(), fn(builder, element) {
    let #(name, tag) = element
    let type_id = type_id.from_tag(tag)
    let name = encode_string(name)
    let encoded_tag = encode_tag(tag)
    builder
    |> bytes_tree.append(<<type_id:int>>)
    |> bytes_tree.append(name)
    |> bytes_tree.append(encoded_tag)
  })
  |> bytes_tree.append(<<type_id.end:int>>)
  |> bytes_tree.to_bit_array
}

fn encode_int_array(int_array: List(Int)) {
  let length = list.length(int_array)
  let encoded_ints =
    list.fold(int_array, <<>>, fn(bit_array, tag) {
      bit_array.append(bit_array, encode_int(tag))
    })
  <<length:int-big-size(32), encoded_ints:bits>>
}

fn encode_long_array(long_array: List(Int)) {
  let length = list.length(long_array)
  let encoded_ints =
    list.fold(long_array, <<>>, fn(bit_array, tag) {
      bit_array.append(bit_array, encode_long(tag))
    })
  <<length:int-big-size(32), encoded_ints:bits>>
}
