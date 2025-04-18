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
  Compound(List(#(String, Tag)))
  IntArray(List(Int))
  LongArray(List(Int))
}
