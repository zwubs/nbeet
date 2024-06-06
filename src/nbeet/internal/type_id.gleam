import nbeet/internal/tag.{type Tag}

pub const end = 0

pub const byte = 1

pub const short = 2

pub const int = 3

pub const long = 4

pub const float = 5

pub const double = 6

pub const byte_array = 7

pub const string = 8

pub const list = 9

pub const compound = 10

pub const int_array = 11

pub const long_array = 12

pub fn from_tag(tag: Tag) {
  case tag {
    tag.End -> end
    tag.Byte(_) -> byte
    tag.Short(_) -> short
    tag.Int(_) -> int
    tag.Long(_) -> long
    tag.Float(_) -> float
    tag.Double(_) -> double
    tag.ByteArray(_) -> byte_array
    tag.String(_) -> string
    tag.List(_) -> list
    tag.Compound(_) -> compound
    tag.IntArray(_) -> int_array
    tag.LongArray(_) -> long_array
  }
}
