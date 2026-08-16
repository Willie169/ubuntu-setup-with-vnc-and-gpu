#### Runtime

```
CUDA_SCALE_LAUNCH_QUEUES=4x GGML_CUDA_ENABLE_UNIFIED_MEMORY=1
```

#### Download

https://huggingface.co/unsloth/Qwen3.5-9B-GGUF

```
llama download -hf unsloth/Qwen3.8-27B-GGUF:Q4_K_M
```

#### Aliases

```
alias qwen-think-cli='CUDA_SCALE_LAUNCH_QUEUES=4x GGML_CUDA_ENABLE_UNIFIED_MEMORY=1 llama cli -hf unsloth/Qwen3.8-27B-GGUF:Q4_K_M --temp 1.0 --top-p 0.95 --top-k 20 --min-p 0.0 --presence-penalty 0.0 --repeat-penalty 1.0 -rea on'

alias qwen-think-serve='CUDA_SCALE_LAUNCH_QUEUES=4x GGML_CUDA_ENABLE_UNIFIED_MEMORY=1 llama serve -hf unsloth/Qwen3.8-27B-GGUF:Q4_K_M --temp 1.0 --top-p 0.95 --top-k 20 --min-p 0.0 --presence-penalty 0.0 --repeat-penalty 1.0 -rea on'
alias qwen-nothink-cli='CUDA_SCALE_LAUNCH_QUEUES=4x GGML_CUDA_ENABLE_UNIFIED_MEMORY=1 llama cli -hf unsloth/Qwen3.8-27B-GGUF:Q4_K_M --temp 0.7 --top-p 0.80 --top-k 20 --min-p 0.0 --presence-penalty 1.5 --repeat-penalty 1.0 -rea off'
alias qwen-nothink-serve='CUDA_SCALE_LAUNCH_QUEUES=4x GGML_CUDA_ENABLE_UNIFIED_MEMORY=1 llama serve -hf unsloth/Qwen3.8-27B-GGUF:Q4_K_M --temp 0.7 --top-p 0.80 --top-k 20 --min-p 0.0 --presence-penalty 1.5 --repeat-penalty 1.0 -rea off'
```
