import gleam/bit_array
import gleam/dict
import gleam/list
import gleam/option
import nbeet/internal/mutf8
import nbeet/internal/tag.{type Tag}
import nbeet/internal/tag_type

pub fn encode(root_tag: Tag, root_name: option.Option(String)) {
  case root_tag {
    tag.Compound(compound) -> {
      bit_array.append(<<>>, encode_tag_type(tag_type.Compound))
      |> bit_array.append(
        root_name |> option.map(encode_string) |> option.unwrap(<<>>),
      )
      |> bit_array.append(encode_compound(compound))
      |> Ok
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

fn encode_tag_type(tag_type: tag_type.TagType) {
  tag_type |> tag_type.to_int |> encode_byte
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
  let bytes = mutf8.bitarray_from_string(string)
  let length = bit_array.byte_size(bytes)
  <<length:int-big-size(16), bytes:bits>>
}

fn encode_list(list: List(Tag)) {
  case list {
    [first_tag, ..] -> {
      bit_array.append(<<>>, encode_tag_type(tag.to_tag_type(first_tag)))
      |> bit_array.append(encode_int(list.length(list)))
      |> list.fold(list, _, fn(bit_array, tag) {
        bit_array.append(bit_array, encode_tag(tag))
      })
    }
    [] ->
      bit_array.append(<<>>, encode_tag_type(tag_type.End))
      |> bit_array.append(encode_int(0))
  }
}

fn encode_compound(compound: List(#(String, Tag))) {
  compound
  |> dict.from_list
  |> dict.to_list
  |> list.fold(<<>>, fn(bit_array, element) {
    let #(name, tag) = element
    bit_array.append(bit_array, tag |> tag.to_tag_type |> encode_tag_type)
    |> bit_array.append(encode_string(name))
    |> bit_array.append(encode_tag(tag))
  })
  |> bit_array.append(encode_tag_type(tag_type.End))
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
