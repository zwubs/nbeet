import gleam/bit_array
import gleam/int
import gleam/result

//  Case    utf8                                                                        mutf8
//  ------------------------------------------------------------------------------------------------------------------------------------------
//  Null    00000000                            <------------special case-------------> 11000000 10000000
//  1-byte  0yyyzzzz                            <----------------same-----------------> 0yyyzzzz
//  2-byte  110xxxyy 10yyzzzz                   <----------------same-----------------> 110xxxyy 10yyzzzz
//  3-byte  1110wwww 10xxxxyy 10yyzzzz          <----------------same-----------------> 1110wwww 10xxxxyy 10yyzzzz
//  4-byte  11110vvv 10vvwwww 10xxxxyy 10yyzzzz <-v is decremented and cast to 4 bits-> 11101101 1010vvvv 10wwwwxx 11101101 1011xxyy 10yyzzzz
//
// Continuation bytes all start with bits `10`. The special cases have
// starting bytes that do not clash with this in either conversion direction
// This means we can use a sliding window to scan ahead for the special cases
// and move all bytes before a match straight into the output

// Encode

pub fn bitarray_from_string(value: String) -> Result(BitArray, String) {
  bitarray_from_string_impl(value |> bit_array.from_string, <<>>)
}

fn bitarray_from_string_impl(
  from: BitArray,
  into: BitArray,
) -> Result(BitArray, String) {
  case split_at_special_cases(from, 0) {
    // Finished
    #(ok_bytes, <<>>) -> Ok(<<into:bits, ok_bytes:bits>>)
    // Null
    #(ok_bytes, <<0, rest:bits>>) ->
      bitarray_from_string_impl(rest, <<
        into:bits,
        ok_bytes:bits,
        0xC0,
        0x80,
      >>)
    // 4-byte -> 6-byte
    #(
      ok_bytes,
      <<
        0b11110:size(5),
        t:bits-size(3),
        0b10:size(2),
        u:bits-size(2),
        w:bits-size(4),
        0b10:size(2),
        x:bits-size(2),
        y:bits-size(4),
        0b10:size(2),
        z:bits-size(6),
        rest:bits,
      >>,
    ) -> {
      let assert <<v>> = <<0b000:size(3), t:bits-size(3), u:bits-size(2)>>
      let v = v - 1
      bitarray_from_string_impl(rest, <<
        into:bits,
        ok_bytes:bits,
        0xed,
        0xa:size(4),
        v:size(4),
        0b10:size(2),
        w:bits-size(4),
        x:bits-size(2),
        0xed,
        0xb:size(4),
        y:bits-size(4),
        0b10:size(2),
        z:bits-size(6),
      >>)
    }
    // Invalid
    #(_, rest) ->
      case rest {
        <<a, _rest:bits>> -> {
          let bits = int.to_base2(a)
          Error(
            "Unexpected byte while encoding string to mutf8, expected the start of a 4-byte character (0b11110xxx) or a null (0b00000000), next byte is: 0x"
            <> bits,
          )
        }

        _ ->
          Error(
            "Less than 1 byte remaining in String while encoding String to mutf8. "
            <> "This shouldn't happen, this is a bug.",
          )
      }
  }
}

// Decode

pub fn string_from_bitarray(data: BitArray) -> Result(String, String) {
  string_from_bitarray_impl(data, <<>>)
}

fn string_from_bitarray_impl(
  from: BitArray,
  into: BitArray,
) -> Result(String, String) {
  case split_at_special_cases(from, 0) {
    // Finished
    #(ok_bytes, <<>>) ->
      <<into:bits, ok_bytes:bits>>
      |> bit_array.to_string
      |> result.map_error(fn(_) { "Failed to decode from mutf8 to utf8" })
    // Null
    #(ok_bytes, <<0xC0, 0x80, rest:bits>>) ->
      string_from_bitarray_impl(rest, <<into:bits, ok_bytes:bits, 0>>)
    // 6-byte into 4-byte
    #(
      ok_bytes,
      <<
        0xed,
        0xa:size(4),
        v:size(4),
        0b10:size(2),
        w:bits-size(4),
        x:bits-size(2),
        0xed,
        0xb:size(4),
        y:bits-size(4),
        0b10:size(2),
        z:bits-size(6),
        rest:bits,
      >>,
    ) -> {
      let v = v + 1
      let assert <<t:bits-size(3), u:bits-size(2)>> = <<v:size(5)>>
      string_from_bitarray_impl(rest, <<
        into:bits,
        ok_bytes:bits,
        0b11110:size(5),
        t:bits-size(3),
        0b10:size(2),
        u:bits-size(2),
        w:bits-size(4),
        0b10:size(2),
        x:bits-size(2),
        y:bits-size(4),
        0b10:size(2),
        z:bits-size(6),
      >>)
    }
    // Invalid
    #(_, rest) ->
      case rest {
        <<a, _rest:bits>> -> {
          let bits = int.to_base2(a)
          Error(
            "Unexpected byte while encoding mutf8 to String, expected the start of a 6-byte character (0b11101101) or a null (0b00000000), next byte is: 0x"
            <> bits,
          )
        }

        _ ->
          Error(
            "Less than 1 byte remaining in bit-string while encoding mutf8 to String. "
            <> "This shouldn't happen, either the passed bit-array does not contain a multiple of 8 bits or this is a bug in the string conversion code.",
          )
      }
  }
}

fn split_at_special_cases(from: BitArray, at: Int) -> #(BitArray, BitArray) {
  case from {
    // Finished
    <<before:bits-size(at)>> -> #(before, <<>>)
    // Null utf8
    <<before:bits-size(at), 0, rest:bits>> -> #(before, <<0, rest:bits>>)
    // Null mutf8
    <<before:bits-size(at), 0xc0, 0x80, rest:bits>> -> #(before, <<
      0xc0,
      0x80,
      rest:bits,
    >>)
    // 4-byte utf8
    <<before:bits-size(at), 0b11110:size(5), rest:bits>> -> #(before, <<
      0b11110:size(5),
      rest:bits,
    >>)
    // 6-byte mutf8
    <<before:bits-size(at), 0xed, 0xA:size(4), rest:bits>> -> #(before, <<
      0xed, 0xA:size(4), rest:bits,
    >>)
    // 2-byte
    <<_before:bits-size(at), 0b110:size(3), _rest:bits>> ->
      split_at_special_cases(from, at + 16)
    // 3-byte
    <<_before:bits-size(at), 0b1110:size(4), _rest:bits>> ->
      split_at_special_cases(from, at + 24)
    // Scan the next byte
    _ -> split_at_special_cases(from, at + 8)
  }
}
