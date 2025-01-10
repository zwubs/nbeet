<div align="center">
  <a href="https://github.com/zwubs/nbeet">
    <img src="https://raw.githubusercontent.com/zwubs/nbeet/main/images/nbeet.png" alt="nbeet logo" width="128" height="128">
  </a>

  <h1 align="center" style="margin-bottom: 0; margin-top: 1rem;">nbeet</h1>

  <p align="center">An NBT encoder and decoder for gleam</p>

[![Package Version](https://img.shields.io/hexpm/v/nbeet)](https://hex.pm/packages/nbeet)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/nbeet/)

</div>

## About
`nbeet` is a gleam package for all your NBT needs. For those that don't know NBT (Named Binary Tag) is a file format utilized by the game Minecraft for storing information. This package focuses on encoding and decoding NBT data and has syntax inspired by [`gleam_json`](https://github.com/gleam-lang/json) and [`bison`](https://github.com/massivefermion/bison) packages.

## Installation
Add `nbeet` to your Gleam project.

```sh
gleam add nbeet
```

## Usage
### Encoding
```gleam
import nbeet.{byte, compound, nbt, string}

pub fn encode_truth() -> Result(BitArray, Nil) {
  let nbt =
    nbt(
      "in beet we",
      compound([#("trust", byte(1)), #("must", string("true")), ])
    )
  nbeet.encode(nbt)
}
```

### Decoding
```gleam
import gleam/dynamic/decode
import gleam/result
import nbeet

pub type InBeetWe {
  InBeetWe(trust: Int, must: String)
}

fn truth_decoder() {
  use trust <- decode.field("trust", decode.int)
  use must <- decode.field("must", decode.string)
  decode.success(InBeetWe(trust, must))
}

fn decode_truth(nbt: BitArray) -> Result(InBeetWe, Nil) {
  let decoder = truth_decoder()
  use #(_, in_beet_we) <- result.try(nbeet.java_decode(nbt, decoder))
  Ok(in_beet_we)
}
```
