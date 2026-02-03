import gleam/dynamic/decode

pub type Error {
  UnableToDecodeTag(tag_type: String, byte_index: Int)
  InvalidTagType(int: Int, byte_index: Int)
  InvalidRootTagType(tag_type: String)
  DecodeErrors(errors: List(decode.DecodeError))
}
