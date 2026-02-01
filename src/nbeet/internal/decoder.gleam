import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/list
import gleam/pair
import gleam/result
import nbeet/internal/mutf8
import nbeet/internal/tag_type

type DecoderResult(value) =
  Result(#(value, BitArray), Nil)

pub fn java_decode(
  bit_array: BitArray,
  decoder: decode.Decoder(t),
) -> Result(#(String, t), List(decode.DecodeError)) {
  use #(root_name, dynamic_value) <- result.try(
    decode_named_root_compound(bit_array)
    |> result.replace_error([]),
  )
  use decoded_value <- result.try(decode.run(dynamic_value, decoder))
  Ok(#(root_name, decoded_value))
}

pub fn java_network_decode(
  bit_array: BitArray,
  decoder: decode.Decoder(t),
) -> Result(t, List(decode.DecodeError)) {
  use dynamic_value <- result.try(
    decode_root_compound(bit_array)
    |> result.replace_error([]),
  )
  decode.run(dynamic_value, decoder)
}

fn decode_named_root_compound(
  bit_array: BitArray,
) -> Result(#(String, Dynamic), Nil) {
  use #(tag_type, bit_array) <- result.try(decode_tag_type(bit_array))
  case tag_type {
    tag_type.Compound -> {
      use #(name, bit_array) <- result.try(decode_string(bit_array))
      use compound <- result.try(decode_tag_of_type(bit_array, tag_type))
      Ok(#(name, pair.first(compound)))
    }
    _ -> Error(Nil)
  }
}

fn decode_root_compound(bit_array: BitArray) -> Result(Dynamic, Nil) {
  use #(tag_type, bit_array) <- result.try(decode_tag_type(bit_array))
  case tag_type {
    tag_type.Compound -> {
      use result <- result.try(decode_tag_of_type(bit_array, tag_type))
      Ok(pair.first(result))
    }
    _ -> Error(Nil)
  }
}

pub fn decode_tag(
  bit_array: BitArray,
  decoder: decode.Decoder(t),
) -> Result(t, List(decode.DecodeError)) {
  use #(tag_type, bit_array) <- result.try(
    decode_tag_type(bit_array) |> result.replace_error([]),
  )
  use #(dynamic_value, _) <- result.try(
    decode_tag_of_type(bit_array, tag_type) |> result.replace_error([]),
  )
  decode.run(dynamic_value, decoder)
}

fn decode_tag_type(
  bit_array: BitArray,
) -> Result(#(tag_type.TagType, BitArray), Nil) {
  use #(byte, bit_array) <- result.try(decode_byte(bit_array))
  use tag_type <- result.try(tag_type.from_int(byte))
  Ok(#(tag_type, bit_array))
}

fn decode_tag_of_type(
  bit_array: BitArray,
  tag_type: tag_type.TagType,
) -> DecoderResult(Dynamic) {
  case tag_type {
    tag_type.End -> Ok(#(dynamic.nil(), bit_array))
    tag_type.Byte -> decode_byte(bit_array) |> to_dynamic(dynamic.int)
    tag_type.Short -> decode_short(bit_array) |> to_dynamic(dynamic.int)
    tag_type.Int -> decode_int(bit_array) |> to_dynamic(dynamic.int)
    tag_type.Long -> decode_long(bit_array) |> to_dynamic(dynamic.int)
    tag_type.Float -> decode_float(bit_array) |> to_dynamic(dynamic.float)
    tag_type.Double -> decode_double(bit_array) |> to_dynamic(dynamic.float)
    tag_type.ByteArray ->
      decode_byte_array(bit_array) |> to_dynamic(dynamic.bit_array)
    tag_type.String -> decode_string(bit_array) |> to_dynamic(dynamic.string)
    tag_type.List -> decode_list(bit_array) |> to_dynamic(dynamic.list)
    tag_type.Compound ->
      decode_compound(bit_array) |> to_dynamic(dynamic.properties)
    tag_type.IntArray -> decode_int_array(bit_array) |> to_dynamic(dynamic.list)
    tag_type.LongArray ->
      decode_long_array(bit_array) |> to_dynamic(dynamic.list)
  }
}

fn to_dynamic(result: DecoderResult(a), converter: fn(a) -> dynamic.Dynamic) {
  result.map(result, pair.map_first(_, converter))
}

fn decode_byte(bit_array: BitArray) -> DecoderResult(Int) {
  case bit_array {
    <<byte:int-signed-big-size(8), bit_array:bytes>> -> Ok(#(byte, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_short(bit_array: BitArray) -> DecoderResult(Int) {
  case bit_array {
    <<short:int-signed-big-size(16), bit_array:bytes>> ->
      Ok(#(short, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_int(bit_array: BitArray) -> DecoderResult(Int) {
  case bit_array {
    <<int:int-signed-big-size(32), bit_array:bytes>> -> Ok(#(int, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_long(bit_array: BitArray) -> DecoderResult(Int) {
  case bit_array {
    <<long:int-signed-big-size(64), bit_array:bytes>> -> Ok(#(long, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_float(bit_array: BitArray) -> DecoderResult(Float) {
  case bit_array {
    <<float:float-big-size(32), bit_array:bytes>> -> Ok(#(float, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_double(bit_array: BitArray) -> DecoderResult(Float) {
  case bit_array {
    <<double:float-big-size(64), bit_array:bytes>> -> Ok(#(double, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_byte_array(bit_array: BitArray) -> DecoderResult(BitArray) {
  case bit_array {
    <<
      length:int-signed-big-size(32),
      byte_array:bytes-size(length),
      bit_array:bytes,
    >> -> Ok(#(byte_array, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_string(bit_array: BitArray) -> DecoderResult(String) {
  case bit_array {
    <<
      length:int-unsigned-big-size(16),
      string_bytes:bytes-size(length),
      bit_array:bytes,
    >> -> {
      use string <- result.try(
        mutf8.string_from_bitarray(string_bytes) |> result.replace_error(Nil),
      )
      Ok(#(string, bit_array))
    }
    _ -> Error(Nil)
  }
}

fn decode_list(bit_array: BitArray) -> DecoderResult(List(Dynamic)) {
  use #(type_id, bit_array) <- result.try(decode_tag_type(bit_array))
  use #(length, bit_array) <- result.try(decode_int(bit_array))
  decode_list_of_length(bit_array, type_id, [], length)
}

fn decode_list_of_length(
  bit_array: BitArray,
  tag_type: tag_type.TagType,
  list: List(Dynamic),
  length: Int,
) -> Result(#(List(Dynamic), BitArray), Nil) {
  case length < 1 {
    True -> Ok(#(list, bit_array))
    False -> {
      use #(element, bit_array) <- result.try(decode_tag_of_type(
        bit_array,
        tag_type,
      ))
      decode_list_of_length(
        bit_array,
        tag_type,
        list.append(list, [element]),
        length - 1,
      )
    }
  }
}

fn decode_compound(
  bit_array: BitArray,
) -> Result(#(List(#(Dynamic, Dynamic)), BitArray), Nil) {
  decode_compound_elements(bit_array, dict.new())
  |> result.map(pair.map_first(_, dict.to_list))
}

fn decode_compound_elements(
  bit_array: BitArray,
  dict: Dict(Dynamic, Dynamic),
) -> Result(#(Dict(Dynamic, Dynamic), BitArray), Nil) {
  use #(tag_type, bit_array) <- result.try(decode_tag_type(bit_array))
  case tag_type {
    tag_type.End -> Ok(#(dict, bit_array))
    _ -> {
      use #(name, bit_array) <- result.try(decode_string(bit_array))
      use #(value, bit_array) <- result.try(decode_tag_of_type(
        bit_array,
        tag_type,
      ))
      decode_compound_elements(
        bit_array,
        dict.insert(dict, dynamic.string(name), value),
      )
    }
  }
}

fn decode_int_array(
  bit_array: BitArray,
) -> Result(#(List(Dynamic), BitArray), Nil) {
  use #(length, bit_array) <- result.try(decode_int(bit_array))
  decode_list_of_length(bit_array, tag_type.Int, [], length)
}

fn decode_long_array(
  bit_array: BitArray,
) -> Result(#(List(Dynamic), BitArray), Nil) {
  use #(length, bit_array) <- result.try(decode_int(bit_array))
  decode_list_of_length(bit_array, tag_type.Long, [], length)
}
