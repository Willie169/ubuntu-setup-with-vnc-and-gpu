#!/usr/bin/env bash

sudo DEBIAN_FRONTEND=noninteractive apt install libssl-dev -y -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-overwrite"
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp || exit
cmake -B build -DGGML_CUDA=ON
cmake --build build --config Release

CUDA_SCALE_LAUNCH_QUEUES=4x
GGML_CUDA_ENABLE_UNIFIED_MEMORY=1
