import gleam/dict.{type Dict}

pub type Tag {
  End
  Byte(Int)
  Short(Int)
  Int(Int)
  Long(Int)
  Float(Float)
  Double(Float)
  ByteArray(BitArray)
  String(String)
  List(List(Tag))
  Compound(Dict(String, Tag))
  IntArray(List(Int))
  LongArray(List(Int))
}
