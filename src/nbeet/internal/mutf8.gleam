import gleam/bit_array
import gleam/int
import gleam/list
import gleam/result
import gleam/string

// Encode

pub fn bitarray_from_string(value: String) -> BitArray {
  bitarray_from_string_impl(<<>>, string.to_utf_codepoints(value))
}

fn bitarray_from_string_impl(
  into acc: BitArray,
  from value: List(UtfCodepoint),
) -> BitArray {
  case value {
    [] -> acc
    [cp, ..rest] ->
      case string.utf_codepoint_to_int(cp) {
        0x00 -> <<0xC0, 0x80>>
        ord if ord <= 0x7F -> <<ord>>
        ord if ord <= 0x7FF -> bit_array_from_2_byte_ordinal(ord)
        ord if ord <= 0xFFFF -> bit_array_from_3_byte_ordinal(ord)
        ord -> bit_array_from_6_byte_ordinal(ord)
      }
      |> bit_array.append(acc, _)
      |> bitarray_from_string_impl(rest)
  }
}

fn bit_array_from_2_byte_ordinal(ord: Int) -> BitArray {
  let byte1 =
    ord
    |> int.bitwise_shift_right(0x06)
    |> int.bitwise_and(0x1F)
    |> int.bitwise_or(0xC0)
  let byte2 = ord |> int.bitwise_and(0x3F) |> int.bitwise_or(0x80)

  <<byte1, byte2>>
}

fn bit_array_from_3_byte_ordinal(ord: Int) -> BitArray {
  let byte1 =
    ord
    |> int.bitwise_shift_right(0x0C)
    |> int.bitwise_and(0x0F)
    |> int.bitwise_or(0xE0)
  let byte2 =
    ord
    |> int.bitwise_shift_right(0x06)
    |> int.bitwise_and(0x3F)
    |> int.bitwise_or(0x80)
  let byte3 = ord |> int.bitwise_and(0x3F) |> int.bitwise_or(0x80)

  <<byte1, byte2, byte3>>
}

fn bit_array_from_6_byte_ordinal(ord: Int) -> BitArray {
  // 11101101 1010wwww 10xxxxxx 11101101 1011yyyy 10zzzzzz
  let byte1 = 0xED
  let byte2 =
    { int.bitwise_shift_right(ord, 0x10) - 1 }
    |> int.bitwise_and(0x0F)
    |> int.bitwise_or(0xA0)
  let byte3 =
    ord
    |> int.bitwise_shift_right(0x0A)
    |> int.bitwise_and(0x3F)
    |> int.bitwise_or(0x80)
  let byte4 = 0xED
  let byte5 =
    ord
    |> int.bitwise_shift_right(0x06)
    |> int.bitwise_and(0x0F)
    |> int.bitwise_or(0xB0)
  let byte6 = ord |> int.bitwise_and(0x3F) |> int.bitwise_or(0x80)

  <<byte1, byte2, byte3, byte4, byte5, byte6>>
}

// Decode

pub fn string_from_bitarray(data: BitArray) -> Result(String, String) {
  string_from_bitarray_impl([], data)
}

fn string_from_bitarray_impl(
  into acc: List(UtfCodepoint),
  from data: BitArray,
) -> Result(String, String) {
  use expected_bytes <- result.try(get_expected_bytes(data))

  case data, expected_bytes {
    <<>>, 0 -> Ok(string.from_utf_codepoints(acc))

    <<0, _rest:bits>>, _ -> Error("Embedded null byte in string bytes")

    <<byte1, rest:bits>>, 1 -> {
      use codepoint <- result.try(codepoint_from_1_byte(byte1))
      string_from_bitarray_impl(list.append(acc, [codepoint]), rest)
    }

    <<byte1, byte2, rest:bits>>, 2 -> {
      use codepoint <- result.try(codepoint_from_2_bytes(byte1, byte2))
      string_from_bitarray_impl(list.append(acc, [codepoint]), rest)
    }

    <<byte1, byte2, byte3, rest:bits>>, 3 -> {
      use codepoint <- result.try(codepoint_from_3_bytes(byte1, byte2, byte3))
      string_from_bitarray_impl(list.append(acc, [codepoint]), rest)
    }

    <<byte1, byte2, byte3, byte4, byte5, byte6, rest:bits>>, 6 -> {
      use codepoint <- result.try(codepoint_from_6_bytes(
        byte1,
        byte2,
        byte3,
        byte4,
        byte5,
        byte6,
      ))
      string_from_bitarray_impl(list.append(acc, [codepoint]), rest)
    }

    _, expected ->
      Error(
        "Expected a "
        <> int.to_string(expected)
        <> "-byte character but there weren't enough left",
      )
  }
}

fn get_expected_bytes(data: BitArray) -> Result(Int, String) {
  case data {
    <<>> -> Ok(0)

    <<byte1, rest:bits>> ->
      case int.bitwise_and(byte1, 0xE0), int.bitwise_and(byte1, 0xF0) {
        0xC0, _ -> Ok(2)

        _, 0xE0 ->
          case rest {
            <<byte2, _byte3, rest2:bits>> ->
              case byte1, int.bitwise_and(byte2, 0xF0) {
                0xED, 0xA0 ->
                  case rest2 {
                    <<byte4, byte5, _rest3:bits>> ->
                      case byte4, int.bitwise_and(byte5, 0xF0) {
                        0xED, 0xB0 -> Ok(6)

                        _, _ -> Ok(3)
                      }

                    _ -> Ok(3)
                  }

                _, _ -> Ok(3)
              }

            _ ->
              Error(
                "Got an indicator for a 3 or 6 byte character but there aren't enough bytes left",
              )
          }

        _, _ -> Ok(1)
      }

    _ -> Ok(1)
  }
}

fn codepoint_from_1_byte(byte1: Int) -> Result(UtfCodepoint, String) {
  string.utf_codepoint(byte1)
  |> result.replace_error(
    "Cannot convert byte to a string char: " <> int.to_string(byte1),
  )
}

fn codepoint_from_2_bytes(
  byte1: Int,
  byte2: Int,
) -> Result(UtfCodepoint, String) {
  int.bitwise_and(byte1, 0x1F)
  |> int.bitwise_shift_left(6)
  |> int.bitwise_or(int.bitwise_and(byte2, 0x3F))
  |> string.utf_codepoint
  |> result.replace_error(
    "Cannot convert bytes to a string char: "
    <> bit_array.inspect(<<byte1, byte2>>),
  )
}

fn codepoint_from_3_bytes(
  byte1: Int,
  byte2: Int,
  byte3: Int,
) -> Result(UtfCodepoint, String) {
  int.bitwise_and(byte1, 0x0F)
  |> int.bitwise_shift_left(0x0C)
  |> int.bitwise_or(
    int.bitwise_and(byte2, 0x3F) |> int.bitwise_shift_left(0x06),
  )
  |> int.bitwise_or(int.bitwise_and(byte3, 0x3F))
  |> string.utf_codepoint
  |> result.replace_error(
    "Cannot convert bytes to a string char: "
    <> bit_array.inspect(<<byte1, byte2, byte3>>),
  )
}

fn codepoint_from_6_bytes(
  byte1: Int,
  byte2: Int,
  byte3: Int,
  byte4: Int,
  byte5: Int,
  byte6: Int,
) -> Result(UtfCodepoint, String) {
  0x10000
  |> int.bitwise_or(
    int.bitwise_and(byte2, 0x0F) |> int.bitwise_shift_left(0x10),
  )
  |> int.bitwise_or(
    int.bitwise_and(byte3, 0x3F) |> int.bitwise_shift_left(0x0A),
  )
  |> int.bitwise_or(
    int.bitwise_and(byte5, 0x0F) |> int.bitwise_shift_left(0x06),
  )
  |> int.bitwise_or(int.bitwise_and(byte6, 0x3F))
  |> string.utf_codepoint
  |> result.replace_error(
    "Cannot convert bytes to a string char: "
    <> bit_array.inspect(<<byte1, byte2, byte3, byte4, byte5, byte6>>),
  )
}
