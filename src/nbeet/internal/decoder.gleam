import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/list
import gleam/pair
import gleam/result
import nbeet/error as public_error
import nbeet/internal/error
import nbeet/internal/mutf8
import nbeet/internal/tag_type

type DecoderResult(value) =
  Result(#(value, BitArray), error.InternalError)

pub fn java_decode(
  bit_array: BitArray,
  decoder: decode.Decoder(t),
) -> Result(#(String, t), public_error.Error) {
  use #(root_name, dynamic_value) <- result.try(
    decode_named_root_compound(bit_array)
    |> result.map_error(error.to_public_error(_, bit_array)),
  )
  use decoded_value <- result.try(
    decode.run(dynamic_value, decoder)
    |> result.map_error(public_error.DecodeErrors),
  )
  Ok(#(root_name, decoded_value))
}

pub fn java_network_decode(
  bit_array: BitArray,
  decoder: decode.Decoder(t),
) -> Result(t, public_error.Error) {
  use dynamic_value <- result.try(
    decode_root_compound(bit_array)
    |> result.map_error(error.to_public_error(_, bit_array)),
  )
  decode.run(dynamic_value, decoder)
  |> result.map_error(public_error.DecodeErrors)
}

fn decode_named_root_compound(
  bit_array: BitArray,
) -> Result(#(String, Dynamic), error.InternalError) {
  use #(tag_type, bit_array) <- result.try(decode_tag_type(bit_array))
  case tag_type {
    tag_type.Compound -> {
      use #(name, bit_array) <- result.try(decode_string(bit_array))
      use compound <- result.try(decode_tag_of_type(bit_array, tag_type))
      Ok(#(name, pair.first(compound)))
    }
    _ -> Error(error.InvalidRootTagType(tag_type))
  }
}

fn decode_root_compound(
  bit_array: BitArray,
) -> Result(Dynamic, error.InternalError) {
  use #(tag_type, bit_array) <- result.try(decode_tag_type(bit_array))
  case tag_type {
    tag_type.Compound -> {
      use result <- result.try(decode_tag_of_type(bit_array, tag_type))
      Ok(pair.first(result))
    }
    _ -> Error(error.InvalidRootTagType(tag_type))
  }
}

pub fn decode_tag(
  original_bit_array: BitArray,
  decoder: decode.Decoder(t),
) -> Result(t, public_error.Error) {
  use #(tag_type, bit_array) <- result.try(
    decode_tag_type(original_bit_array)
    |> result.map_error(error.to_public_error(_, original_bit_array)),
  )
  use #(dynamic_value, _) <- result.try(
    decode_tag_of_type(bit_array, tag_type)
    |> result.map_error(error.to_public_error(_, original_bit_array)),
  )
  decode.run(dynamic_value, decoder)
  |> result.map_error(public_error.DecodeErrors)
}

fn decode_tag_type(
  bit_array: BitArray,
) -> Result(#(tag_type.TagType, BitArray), error.InternalError) {
  use #(byte, new_bit_array) <- result.try(decode_byte(bit_array))
  use tag_type <- result.try(
    tag_type.from_int(byte)
    |> result.map_error(error.InvalidTagType(_, bit_array)),
  )
  Ok(#(tag_type, new_bit_array))
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
    _ -> Error(error.UnableToDecodeTag(tag_type.Byte, bit_array))
  }
}

fn decode_short(bit_array: BitArray) -> DecoderResult(Int) {
  case bit_array {
    <<short:int-signed-big-size(16), bit_array:bytes>> ->
      Ok(#(short, bit_array))
    _ -> Error(error.UnableToDecodeTag(tag_type.Short, bit_array))
  }
}

fn decode_int(bit_array: BitArray) -> DecoderResult(Int) {
  case bit_array {
    <<int:int-signed-big-size(32), bit_array:bytes>> -> Ok(#(int, bit_array))
    _ -> Error(error.UnableToDecodeTag(tag_type.Int, bit_array))
  }
}

fn decode_long(bit_array: BitArray) -> DecoderResult(Int) {
  case bit_array {
    <<long:int-signed-big-size(64), bit_array:bytes>> -> Ok(#(long, bit_array))
    _ -> Error(error.UnableToDecodeTag(tag_type.Long, bit_array))
  }
}

fn decode_float(bit_array: BitArray) -> DecoderResult(Float) {
  case bit_array {
    <<float:float-big-size(32), bit_array:bytes>> -> Ok(#(float, bit_array))
    _ -> Error(error.UnableToDecodeTag(tag_type.Float, bit_array))
  }
}

fn decode_double(bit_array: BitArray) -> DecoderResult(Float) {
  case bit_array {
    <<double:float-big-size(64), bit_array:bytes>> -> Ok(#(double, bit_array))
    _ -> Error(error.UnableToDecodeTag(tag_type.Double, bit_array))
  }
}

fn decode_byte_array(bit_array: BitArray) -> DecoderResult(BitArray) {
  case bit_array {
    <<
      length:int-signed-big-size(32),
      byte_array:bytes-size(length),
      bit_array:bytes,
    >> -> Ok(#(byte_array, bit_array))
    _ -> Error(error.UnableToDecodeTag(tag_type.ByteArray, bit_array))
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
  |> result.replace_error(error.UnableToDecodeTag(tag_type.String, bit_array))
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
) -> Result(#(List(Dynamic), BitArray), error.InternalError) {
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
) -> Result(#(List(#(Dynamic, Dynamic)), BitArray), error.InternalError) {
  decode_compound_elements(bit_array, dict.new())
  |> result.map(pair.map_first(_, dict.to_list))
}

fn decode_compound_elements(
  bit_array: BitArray,
  dict: Dict(Dynamic, Dynamic),
) -> Result(#(Dict(Dynamic, Dynamic), BitArray), error.InternalError) {
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
) -> Result(#(List(Dynamic), BitArray), error.InternalError) {
  use #(length, bit_array) <- result.try(decode_int(bit_array))
  decode_list_of_length(bit_array, tag_type.Int, [], length)
}

fn decode_long_array(
  bit_array: BitArray,
) -> Result(#(List(Dynamic), BitArray), error.InternalError) {
  use #(length, bit_array) <- result.try(decode_int(bit_array))
  decode_list_of_length(bit_array, tag_type.Long, [], length)
}
