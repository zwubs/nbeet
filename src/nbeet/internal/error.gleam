import gleam/bit_array
import nbeet/error
import nbeet/internal/tag_type

pub type InternalError {
  UnableToDecodeTag(tag_type: tag_type.TagType, from: BitArray)
  InvalidTagType(int: Int, from: BitArray)
  InvalidRootTagType(tag_type: tag_type.TagType)
}

pub fn to_public_error(
  internal_error: InternalError,
  original_bit_array: BitArray,
) {
  let original_length = bit_array.byte_size(original_bit_array)
  case internal_error {
    UnableToDecodeTag(tag_type, from) ->
      error.UnableToDecodeTag(
        tag_type.to_string(tag_type),
        original_length - bit_array.byte_size(from),
      )
    InvalidTagType(int:, from:) ->
      error.InvalidTagType(int, original_length - bit_array.byte_size(from))
    InvalidRootTagType(tag_type:) ->
      error.InvalidRootTagType(tag_type.to_string(tag_type))
  }
}
