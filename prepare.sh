#!/bin/bash

# Source the script prelude
source "scripts/_prelude.sh"
source .env

PROJECT_DIR=$(pwd)
SCRIPT_DIR="${PROJECT_DIR}/scripts"
CIRCOM_DIR="${PROJECT_DIR}/core/circuits"

compile_circuit() {
    local circuit_dir=$1
    local circuit_file=$2
    local target_file="$circuit_dir/target/$(basename $circuit_file .circom).r1cs"

    print_action "[core/circom] Compiling $circuit_file example circuit..."
    if [ ! -f "$target_file" ]; then
        "${SCRIPT_DIR}/compile.sh" $circuit_dir $circuit_file
    else
        echo "File $target_file already exists, skipping compilation."
    fi
}

npm_install() {
    local circuit_dir=$1

    if [[ ! -d "$circuit_dir/node_modules" ]]; then
        echo "Installing npm dependencies for $circuit_dir..."
        (cd "${circuit_dir}" && npm install)
    fi
}

generate_witness() {
    local circuit_dir=$1
    local circuit_name=$2

    pushd $circuit_dir/target > /dev/null
        # Build circuit cpp
        pushd "$circuit_name"_cpp/ > /dev/null
        make -j12
        mkdir -p ../build
        cp "$circuit_name" ../build/
        popd > /dev/null
    # Generate witness
    node "${circuit_name}_js/generate_witness.js" "${circuit_name}_js/${circuit_name}.wasm" ../input.json ./build/${circuit_name}.wtns
    popd > /dev/null
}

# Check if arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <circuit>"
    exit 1
fi

# Read parameters from command line
circuit=$1
circuit_dir="${CIRCOM_DIR}/$1"

# Call functions with the provided parameters
npm_install $circuit_dir
compile_circuit $circuit_dir "${circuit}.circom"
# generate_witness $dirname $circom_name
print_action "[core/circom] Running trusted setup for ${circuit}..."
"${SCRIPT_DIR}/trusted_setup.sh" $circuit_dir $PTAU_NUM $circuit


# Setup and compile keccak256
# npm_install keccak256
# compile_circuit keccak256 keccak256.circom
# generate_witness keccak256 keccak256

# Setup and compile rsa
# npm_install rsa
# compile_circuit rsa rsa.circom
# generate_witness rsa rsa

# Setup and compile complex-circuit
# npm_install complex-circuit
# for size in {100k,200k,400k,800k,1000k,1200k,1600k,3200k}
# do
#     compile_circuit complex-circuit complex-circuit-${size}-${size}.circom
#     generate_witness complex-circuit complex-circuit-${size}-${size}
# done

# Run trusted setup for keccak256
# print_action "[core/circom] Running trusted setup for keccak256..."
# ./scripts/trusted_setup.sh keccak256 25 keccak256

# Run trusted setup for rsa
# print_action "[core/circom] Running trusted setup for rsa..."
# ./scripts/trusted_setup.sh rsa 21 rsa

# Run trusted setup for complex circuit
# print_action "[core/circom] Running trusted setup for complex circuit..."
# for size in {100k,200k,400k,800k,1000k,1200k,1600k,3200k}
# do
#     ./scripts/trusted_setup.sh complex-circuit 25 complex-circuit-${size}-${size}
# done
