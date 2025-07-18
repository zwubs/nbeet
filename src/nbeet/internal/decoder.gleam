import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/list
import gleam/pair
import gleam/result
import nbeet/internal/mutf8
import nbeet/internal/type_id as type_ids

type DecoderResult =
  Result(#(Dynamic, BitArray), Nil)

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
  use decoded_value <- result.try(decode.run(dynamic_value, decoder))
  Ok(decoded_value)
}

fn decode_named_root_compound(
  bit_array: BitArray,
) -> Result(#(String, Dynamic), Nil) {
  case bit_array {
    <<type_id:int, bit_array:bits>> if type_id == type_ids.compound -> {
      use #(name, bit_array) <- result.try(decode_string(bit_array))
      use compound <- result.try(decode_tag_of_type(bit_array, type_id))
      Ok(#(name, pair.first(compound)))
    }
    _ -> Error(Nil)
  }
}

fn decode_root_compound(bit_array: BitArray) -> Result(Dynamic, Nil) {
  case bit_array {
    <<type_id:int, bit_array:bits>> if type_id == type_ids.compound -> {
      use result <- result.try(decode_tag_of_type(bit_array, type_id))
      Ok(pair.first(result))
    }
    _ -> Error(Nil)
  }
}

fn decode_tag_of_type(bit_array: BitArray, type_id: Int) -> DecoderResult {
  case type_id {
    _ if type_id == type_ids.end -> Ok(#(dynamic.nil(), bit_array))
    _ if type_id == type_ids.byte -> wrap_int(decode_byte(bit_array))
    _ if type_id == type_ids.short -> wrap_int(decode_short(bit_array))
    _ if type_id == type_ids.int -> wrap_int(decode_int(bit_array))
    _ if type_id == type_ids.long -> wrap_int(decode_long(bit_array))
    _ if type_id == type_ids.float -> wrap_float(decode_float(bit_array))
    _ if type_id == type_ids.double -> wrap_float(decode_double(bit_array))
    _ if type_id == type_ids.byte_array ->
      wrap_bit_array(decode_byte_array(bit_array))
    _ if type_id == type_ids.string -> wrap_string(decode_string(bit_array))
    _ if type_id == type_ids.list -> wrap_list(decode_list(bit_array))
    _ if type_id == type_ids.compound ->
      wrap_compound(decode_compound(bit_array))
    _ if type_id == type_ids.int_array -> wrap_list(decode_int_array(bit_array))
    _ if type_id == type_ids.long_array ->
      wrap_list(decode_long_array(bit_array))
    _ -> Error(Nil)
  }
}

fn wrap_int(
  result: Result(#(Int, BitArray), Nil),
) -> Result(#(Dynamic, BitArray), Nil) {
  case result {
    Ok(#(value, bit_array)) -> Ok(#(dynamic.int(value), bit_array))
    _ -> Error(Nil)
  }
}

fn wrap_float(
  result: Result(#(Float, BitArray), Nil),
) -> Result(#(Dynamic, BitArray), Nil) {
  case result {
    Ok(#(value, bit_array)) -> Ok(#(dynamic.float(value), bit_array))
    _ -> Error(Nil)
  }
}

fn wrap_bit_array(
  result: Result(#(BitArray, BitArray), Nil),
) -> Result(#(Dynamic, BitArray), Nil) {
  case result {
    Ok(#(value, bit_array)) -> Ok(#(dynamic.bit_array(value), bit_array))
    _ -> Error(Nil)
  }
}

fn wrap_string(
  result: Result(#(String, BitArray), Nil),
) -> Result(#(Dynamic, BitArray), Nil) {
  case result {
    Ok(#(value, bit_array)) -> Ok(#(dynamic.string(value), bit_array))
    _ -> Error(Nil)
  }
}

fn wrap_list(
  result: Result(#(List(Dynamic), BitArray), Nil),
) -> Result(#(Dynamic, BitArray), Nil) {
  case result {
    Ok(#(value, bit_array)) -> Ok(#(dynamic.list(value), bit_array))
    _ -> Error(Nil)
  }
}

fn wrap_compound(
  result: Result(#(Dict(String, Dynamic), BitArray), Nil),
) -> Result(#(Dynamic, BitArray), Nil) {
  case result {
    Ok(#(value, bit_array)) ->
      Ok(#(
        value
          |> dict.to_list
          |> list.map(fn(key_val: #(String, Dynamic)) -> #(Dynamic, Dynamic) {
            let #(key, val) = key_val
            #(dynamic.string(key), val)
          })
          |> dynamic.properties,
        bit_array,
      ))
    _ -> Error(Nil)
  }
}

fn decode_byte(bit_array: BitArray) -> Result(#(Int, BitArray), Nil) {
  case bit_array {
    <<byte:int-signed-big-size(8), bit_array:bytes>> -> Ok(#(byte, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_short(bit_array: BitArray) -> Result(#(Int, BitArray), Nil) {
  case bit_array {
    <<short:int-signed-big-size(16), bit_array:bytes>> ->
      Ok(#(short, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_int(bit_array: BitArray) -> Result(#(Int, BitArray), Nil) {
  case bit_array {
    <<int:int-signed-big-size(32), bit_array:bytes>> -> Ok(#(int, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_long(bit_array: BitArray) -> Result(#(Int, BitArray), Nil) {
  case bit_array {
    <<long:int-signed-big-size(64), bit_array:bytes>> -> Ok(#(long, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_float(bit_array: BitArray) -> Result(#(Float, BitArray), Nil) {
  case bit_array {
    <<float:float-big-size(32), bit_array:bytes>> -> Ok(#(float, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_double(bit_array: BitArray) -> Result(#(Float, BitArray), Nil) {
  case bit_array {
    <<double:float-big-size(64), bit_array:bytes>> -> Ok(#(double, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_byte_array(bit_array: BitArray) -> Result(#(BitArray, BitArray), Nil) {
  use #(length, bit_array) <- result.try(decode_int(bit_array))
  case bit_array {
    <<byte_array:bytes-size(length), bit_array:bytes>> ->
      Ok(#(byte_array, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_string(bit_array: BitArray) -> Result(#(String, BitArray), Nil) {
  case bit_array {
    <<
      length:int-unsigned-big-size(16),
      string_bytes:bytes-size(length),
      bit_array:bytes,
    >> -> {
      use string <- result.try(string_from_bytes(string_bytes))
      Ok(#(string, bit_array))
    }
    _ -> Error(Nil)
  }
}

fn string_from_bytes(bit_array: BitArray) -> Result(String, Nil) {
  mutf8.string_from_bitarray(bit_array) |> result.replace_error(Nil)
}

fn decode_list(bit_array: BitArray) -> Result(#(List(Dynamic), BitArray), Nil) {
  use #(type_id, bit_array) <- result.try(decode_byte(bit_array))
  use #(length, bit_array) <- result.try(decode_int(bit_array))
  decode_list_of_length(bit_array, type_id, [], length)
}

fn decode_list_of_length(
  bit_array: BitArray,
  type_id: Int,
  list: List(Dynamic),
  length: Int,
) -> Result(#(List(Dynamic), BitArray), Nil) {
  case length < 1 {
    True -> Ok(#(list, bit_array))
    False -> {
      use #(element, bit_array) <- result.try(decode_tag_of_type(
        bit_array,
        type_id,
      ))
      decode_list_of_length(
        bit_array,
        type_id,
        list.append(list, [element]),
        length - 1,
      )
    }
  }
}

fn decode_compound(
  bit_array: BitArray,
) -> Result(#(Dict(String, Dynamic), BitArray), Nil) {
  decode_compound_elements(bit_array, dict.new())
}

fn decode_compound_elements(
  bit_array: BitArray,
  dict: Dict(String, Dynamic),
) -> Result(#(Dict(String, Dynamic), BitArray), Nil) {
  use #(type_id, bit_array) <- result.try(decode_byte(bit_array))
  case type_id == type_ids.end {
    True -> Ok(#(dict, bit_array))
    False -> {
      use #(name, bit_array) <- result.try(decode_string(bit_array))
      use #(value, bit_array) <- result.try(decode_tag_of_type(
        bit_array,
        type_id,
      ))
      decode_compound_elements(bit_array, dict.insert(dict, name, value))
    }
  }
}

fn decode_int_array(
  bit_array: BitArray,
) -> Result(#(List(Dynamic), BitArray), Nil) {
  use #(length, bit_array) <- result.try(decode_int(bit_array))
  decode_list_of_length(bit_array, type_ids.int, [], length)
}

fn decode_long_array(
  bit_array: BitArray,
) -> Result(#(List(Dynamic), BitArray), Nil) {
  use #(length, bit_array) <- result.try(decode_int(bit_array))
  decode_list_of_length(bit_array, type_ids.long, [], length)
}
