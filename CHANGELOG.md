# Changelog

## v2.0.0 - 2026-02-02

- The `nbeet` module has been moved to `nbeet/nbt`.
- Updated `java_encode` & `java_network_encode` to return `BitArray`s instead of `Result`s.
- Improvements to the string MUTF-8 encoding/decoding performance (thank you [TigerWalts](https://github.com/TigerWalts)!).
- Encoding performance improvments.
- Added `encode_tag` and `decode_tag` functions.
- Added `bool` function to simplify encoding booleans as bytes.
- Added new public error type with helpful debugging information.
- Removed `gzip` module.
