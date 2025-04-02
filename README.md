# Mopro Benchmark

Benchmark Mopro's performance on different circuits, on different phones.

Mopro is a mobile ZK proving framework, unlocking real Zero-Knowledge: https://github.com/zkmopro/mopro

# Circom Results
> Mopro version: v0.0.1
> Benchmark date: 2024-07

| Circuit | Device | Time (s) | Memory (MB) | zkey Size (MB) | Constraints |
|---------|---------|-----------|-------------|--------------|-------------|
| efficient-zk-ecdsa | iPhone 15 Pro Simulator on M1 Pro | 10.5 | 200 | 119 | 163239 |
| efficient-zk-ecdsa | Xiaomi 12SU | 13.5 | 470 | 119 | 163239 |
| efficient-zk-ecdsa | Xiaomi 14U | 15.0 | 470 | 119 | 163239 |
| eddsa-babyjubjub | Xiaomi 14U | 0.4 | 113 | 3 | 5712 |
| RSA | Xiaomi 14U | 12.2 | 480 | 129 | 157746 |
| Dummy-3200k | Xiaomi 12SU | 75.0 | 4900 | 1500 | 3200000 |
| Dummy-1600k | iPhone 15 Pro Simulator on M1 Pro | 14.5 | 1400 | 750 | 1600000 |
| Dummy-1600k | iPhone 13 | 29.0 | 1400 | 750 | 1600000 |
| Dummy-1600k | Xiaomi 12SU | 35.0 | 2500 | 750 | 1600000 |
| Dummy-1200k | iPhone 15 Pro Simulator on M1 Pro | 13.0 | 1200 | 600 | 1200000 |
| Dummy-1200k | iPhone 13 | 23.0 | 1200 | 600 | 1200000 |
| Dummy-1200k | Xiaomi 12SU | 25.0 | 2200 | 600 | 1200000 |
| Dummy-400k | iPhone 15 Pro Simulator on M1 Pro | 3.3 | 270 | 190 | 400000 |
| Dummy-400k | iPhone 13 | 7.0 | 390 | 190 | 400000 |
| Dummy-400k | Xiaomi 12SU | 11.0 | 700 | 190 | 400000 |
| Dummy-100k | iPhone 15 Pro Simulator on M1 Pro | 0.9 | 100 | 50 | 100000 |
| Dummy-100k | iPhone 13 | 2.0 | 100 | 50 | 100000 |
| Dummy-100k | Xiaomi 12SU | 2.7 | 256 | 50 | 100000 |

Note:
- [efficient-zk-ecdsa](https://github.com/personaelabs/efficient-zk-ecdsa): an highly optimized ECDSA circuit.
- [eddsa-babyjubjub](https://github.com/iden3/circomlib/blob/master/circuits/eddsamimc.circom): a EDDSA circuit on BabyJubJub curve. native field arithmetic, so that it's constraints are much lower.
- RSA: Verify RSA signature
- Dummy-3200k from mopro, a dummy circuit with 3200k constraints. Since Groth16 proving time only depends on constraints, this is a good proxy for the proving time of a complex circuit.

## Usage

### Prepare
Install Mopro v0.0.1, docs: https://zkmopro.org/docs/getting-started/

```sh
# See all available circuits under core/circuits
./prepare.sh eddsa
./prepare.sh ecdsa
```

In `mopro-config.toml`, set the `circuit` field to the circuit you want to use. 

### Build

`mopro build --platforms android` or `mopro build --platforms ios`

### Test

`mopro test`

### Web Server
```sh
# Copy final.zkey and wasm to web/public, used in web prover
find ./core/circuits/complex-circuit/target -type f \( -name "*_final.zkey" -o -name "*.wasm" \) -exec cp {} ./web/public \;
```