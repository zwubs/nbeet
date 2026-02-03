import gleam/string

pub type TagType {
  End
  Byte
  Short
  Int
  Long
  Float
  Double
  ByteArray
  String
  List
  Compound
  IntArray
  LongArray
}

pub fn to_int(tag_type: TagType) {
  case tag_type {
    End -> 0
    Byte -> 1
    Short -> 2
    Int -> 3
    Long -> 4
    Float -> 5
    Double -> 6
    ByteArray -> 7
    String -> 8
    List -> 9
    Compound -> 10
    IntArray -> 11
    LongArray -> 12
  }
}

pub fn from_int(int: Int) -> Result(TagType, Int) {
  case int {
    0 -> Ok(End)
    1 -> Ok(Byte)
    2 -> Ok(Short)
    3 -> Ok(Int)
    4 -> Ok(Long)
    5 -> Ok(Float)
    6 -> Ok(Double)
    7 -> Ok(ByteArray)
    8 -> Ok(String)
    9 -> Ok(List)
    10 -> Ok(Compound)
    11 -> Ok(IntArray)
    12 -> Ok(LongArray)
    _ -> Error(int)
  }
}

pub fn to_string(tag_type: TagType) {
  string.inspect(tag_type)
}
