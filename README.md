# mopro-example-app

This is an example project generated by `mopro-cli`.

## Documentation

See https://github.com/zkmopro/mopro

## Usage

### Prepare

```sh
# Build complex-circuit under mopro root repo
# Then copy the circuits to this project
cp -r ../mopro/mopro-core/examples/circom/complex-circuit ./core/circuits/complex-circuit
```
### Build

`mopro build` or `mopro build --platforms ios`

### Test

`mopro test`