import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic, from}
import gleam/dynamic/decode
import gleam/list
import gleam/pair
import gleam/result
import nbeet/internal/mutf8
import nbeet/internal/type_id as type_ids

type DecoderResult =
  Result(#(Dynamic, BitArray), Nil)

pub fn java_decode(bit_array: BitArray, decoder: decode.Decoder(t)) {
  use #(root_name, dynamic_value) <- result.then(
    decode_named_root_compound(bit_array)
    |> result.replace_error([]),
  )
  use decoded_value <- result.try(decode.run(dynamic_value, decoder))
  Ok(#(root_name, decoded_value))
}

pub fn java_network_decode(bit_array: BitArray, decoder: decode.Decoder(t)) {
  use dynamic_value <- result.then(
    decode_root_compound(bit_array)
    |> result.replace_error([]),
  )
  use decoded_value <- result.try(decode.run(dynamic_value, decoder))
  Ok(decoded_value)
}

fn decode_named_root_compound(bit_array: BitArray) {
  case bit_array {
    <<type_id:int, bit_array:bits>> if type_id == type_ids.compound -> {
      use #(name, bit_array) <- result.try(decode_string(bit_array))
      use compound <- result.try(decode_tag_of_type(bit_array, type_id))
      Ok(#(name, pair.first(compound)))
    }
    _ -> Error(Nil)
  }
}

fn decode_root_compound(bit_array: BitArray) {
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
    _ if type_id == type_ids.end -> wrap(Ok(#(Nil, bit_array)))
    _ if type_id == type_ids.byte -> wrap(decode_byte(bit_array))
    _ if type_id == type_ids.short -> wrap(decode_short(bit_array))
    _ if type_id == type_ids.int -> wrap(decode_int(bit_array))
    _ if type_id == type_ids.long -> wrap(decode_long(bit_array))
    _ if type_id == type_ids.float -> wrap(decode_float(bit_array))
    _ if type_id == type_ids.double -> wrap(decode_double(bit_array))
    _ if type_id == type_ids.byte_array -> wrap(decode_byte_array(bit_array))
    _ if type_id == type_ids.string -> wrap(decode_string(bit_array))
    _ if type_id == type_ids.list -> wrap(decode_list(bit_array))
    _ if type_id == type_ids.compound -> wrap(decode_compound(bit_array))
    _ if type_id == type_ids.int_array -> wrap(decode_int_array(bit_array))
    _ if type_id == type_ids.long_array -> wrap(decode_long_array(bit_array))
    _ -> Error(Nil)
  }
}

fn wrap(result: Result(#(value, BitArray), Nil)) {
  case result {
    Ok(#(value, bit_array)) -> Ok(#(from(value), bit_array))
    _ -> Error(Nil)
  }
}

fn decode_byte(bit_array: BitArray) {
  case bit_array {
    <<byte:int-signed-big-size(8), bit_array:bytes>> -> Ok(#(byte, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_short(bit_array: BitArray) {
  case bit_array {
    <<short:int-signed-big-size(16), bit_array:bytes>> ->
      Ok(#(short, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_int(bit_array: BitArray) {
  case bit_array {
    <<int:int-signed-big-size(32), bit_array:bytes>> -> Ok(#(int, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_long(bit_array: BitArray) {
  case bit_array {
    <<long:int-signed-big-size(64), bit_array:bytes>> -> Ok(#(long, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_float(bit_array: BitArray) {
  case bit_array {
    <<float:float-big-size(32), bit_array:bytes>> -> Ok(#(float, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_double(bit_array: BitArray) {
  case bit_array {
    <<double:float-big-size(64), bit_array:bytes>> -> Ok(#(double, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_byte_array(bit_array: BitArray) {
  use #(length, bit_array) <- result.try(decode_int(bit_array))
  case bit_array {
    <<byte_array:bytes-size(length), bit_array:bytes>> ->
      Ok(#(byte_array, bit_array))
    _ -> Error(Nil)
  }
}

fn decode_string(bit_array: BitArray) {
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

fn string_from_bytes(bit_array: BitArray) {
  mutf8.string_from_bitarray(bit_array) |> result.replace_error(Nil)
}

fn decode_list(bit_array: BitArray) {
  use #(type_id, bit_array) <- result.try(decode_byte(bit_array))
  use #(length, bit_array) <- result.try(decode_int(bit_array))
  decode_list_of_length(bit_array, type_id, [], length)
}

fn decode_list_of_length(
  bit_array: BitArray,
  type_id: Int,
  list: List(Dynamic),
  length: Int,
) {
  case length {
    l if l < 1 -> Ok(#(list, bit_array))
    _ -> {
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

fn decode_compound(bit_array: BitArray) {
  decode_compound_elements(bit_array, dict.new())
}

fn decode_compound_elements(bit_array: BitArray, dict: Dict(String, Dynamic)) {
  use #(type_id, bit_array) <- result.try(decode_byte(bit_array))
  case type_id {
    _ if type_id == type_ids.end -> Ok(#(dict, bit_array))
    _ -> {
      use #(name, bit_array) <- result.try(decode_string(bit_array))
      use #(value, bit_array) <- result.try(decode_tag_of_type(
        bit_array,
        type_id,
      ))
      decode_compound_elements(bit_array, dict.insert(dict, name, value))
    }
  }
}

fn decode_int_array(bit_array: BitArray) {
  use #(length, bit_array) <- result.try(decode_int(bit_array))
  decode_list_of_length(bit_array, type_ids.int, [], length)
}

fn decode_long_array(bit_array: BitArray) {
  use #(length, bit_array) <- result.try(decode_int(bit_array))
  decode_list_of_length(bit_array, type_ids.long, [], length)
}
