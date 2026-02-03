import gleam/bit_array
import gleam/bool
import gleam/bytes_tree.{type BytesTree}
import gleam/list
import gleam/pair
import gleam/set
import nbeet/internal/mutf8
import nbeet/internal/tag.{type Tag}
import nbeet/internal/tag_type

pub fn java_network_encode(tag: Tag) {
  let assert tag.Compound(compound) = tag
  bytes_tree.new()
  |> encode_tag_type(tag_type.Compound)
  |> encode_compound(compound)
  |> bytes_tree.to_bit_array()
}

pub fn java_encode(tag: Tag, root_name: String) {
  let assert tag.Compound(compound) = tag
  bytes_tree.new()
  |> encode_tag_type(tag_type.Compound)
  |> encode_string(root_name)
  |> encode_compound(compound)
  |> bytes_tree.to_bit_array()
}

pub fn encode_tag_with_type(tag: Tag) {
  bytes_tree.new()
  |> encode_tag_type(tag.to_tag_type(tag))
  |> encode_tag(tag)
  |> bytes_tree.to_bit_array()
}

pub fn encode_tag(tree: BytesTree, tag: Tag) {
  tree
  |> case tag {
    tag.End -> fn(tree) { tree }
    tag.Byte(byte) -> encode_byte(_, byte)
    tag.Short(short) -> encode_short(_, short)
    tag.Int(int) -> encode_int(_, int)
    tag.Long(long) -> encode_long(_, long)
    tag.Float(float) -> encode_float(_, float)
    tag.Double(double) -> encode_double(_, double)
    tag.ByteArray(byte_array) -> encode_byte_array(_, byte_array)
    tag.String(string) -> encode_string(_, string)
    tag.List(list) -> encode_list(_, list)
    tag.Compound(compound) -> encode_compound(_, compound)
    tag.IntArray(int_array) -> encode_int_array(_, int_array)
    tag.LongArray(long_array) -> encode_long_array(_, long_array)
  }
}

fn encode_tag_type(tree: BytesTree, tag_type: tag_type.TagType) {
  tag_type |> tag_type.to_int |> encode_byte(tree, _)
}

fn encode_byte(tree: BytesTree, byte: Int) {
  bytes_tree.append(tree, <<byte:int-big-size(8)>>)
}

fn encode_short(tree: BytesTree, short: Int) {
  bytes_tree.append(tree, <<short:int-big-size(16)>>)
}

fn encode_int(tree: BytesTree, int: Int) {
  bytes_tree.append(tree, <<int:int-big-size(32)>>)
}

fn encode_long(tree: BytesTree, long: Int) {
  bytes_tree.append(tree, <<long:int-big-size(64)>>)
}

fn encode_float(tree: BytesTree, float: Float) {
  bytes_tree.append(tree, <<float:float-big-size(32)>>)
}

fn encode_double(tree: BytesTree, double: Float) {
  bytes_tree.append(tree, <<double:float-big-size(64)>>)
}

fn encode_byte_array(tree: BytesTree, byte_array: BitArray) {
  let length = bit_array.byte_size(byte_array)
  bytes_tree.append(tree, <<length:int-big-size(32), byte_array:bits>>)
}

fn encode_string(tree: BytesTree, string: String) {
  let assert Ok(bytes) = mutf8.bitarray_from_string(string)
  let length = bit_array.byte_size(bytes)
  bytes_tree.append(tree, <<length:int-big-size(16), bytes:bits>>)
}

fn encode_list(tree: BytesTree, list: List(Tag)) {
  case list {
    [first_tag, ..] -> {
      tree
      |> encode_tag_type(tag.to_tag_type(first_tag))
      |> encode_int(list.length(list))
      |> list.fold(list, _, encode_tag)
    }
    [] ->
      tree
      |> encode_tag_type(tag_type.End)
      |> encode_int(0)
  }
}

fn encode_compound(tree: BytesTree, compound: List(#(String, Tag))) {
  // Avoiding dict to preserve list order for testing
  let unique_elements =
    list.fold(compound, #(set.new(), []), fn(folded, element) {
      let #(names, elements) = folded
      let #(name, _) = element
      use <- bool.guard(set.contains(names, name), folded)
      #(names, [element, ..elements])
    })
    |> pair.second()

  list.fold_right(unique_elements, tree, fn(tree, element) {
    let #(name, tag) = element
    tree
    |> encode_tag_type(tag.to_tag_type(tag))
    |> encode_string(name)
    |> encode_tag(tag)
  })
  |> encode_tag_type(tag_type.End)
}

fn encode_int_array(tree: BytesTree, int_array: List(Int)) {
  tree
  |> encode_int(list.length(int_array))
  |> list.fold(int_array, _, encode_int)
}

fn encode_long_array(tree: BytesTree, long_array: List(Int)) {
  tree
  |> encode_int(list.length(long_array))
  |> list.fold(long_array, _, encode_long)
}
