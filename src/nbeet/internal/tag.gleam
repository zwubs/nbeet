import nbeet/internal/tag_type

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

pub fn to_tag_type(tag: Tag) -> tag_type.TagType {
  case tag {
    End -> tag_type.End
    Byte(_) -> tag_type.Byte
    Short(_) -> tag_type.Short
    Int(_) -> tag_type.Int
    Long(_) -> tag_type.Long
    Float(_) -> tag_type.Float
    Double(_) -> tag_type.Double
    ByteArray(_) -> tag_type.ByteArray
    String(_) -> tag_type.String
    List(_) -> tag_type.List
    Compound(_) -> tag_type.Compound
    IntArray(_) -> tag_type.IntArray
    LongArray(_) -> tag_type.LongArray
  }
}
