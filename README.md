# API

The centralized API definitions for ChoreRewards.

All API definitions should defined using the [`protocol buffers`][protocol-buffers] and live in the `proto/` directory, following the convention of: `proto/<service>/<version>/<service>.proto`.

The generated code also live in this repo following the convention of `<service>/<version>/`.

## Usage

All commands are accessible via `make`. Some of the more common ones needed are:

- `deps` - Install all the dependences
- `protodeps` - Update the third party proto dependencies
- `protos` - Generates any `*.pb.*` files.

### Using third party definitions

All third party dependencies should be added to `protodeps.toml` and downloaded with `make protodeps`. Files are downloaded to `third_party/proto`

[protocol-buffers]: https://developers.google.com/protocol-buffers/
