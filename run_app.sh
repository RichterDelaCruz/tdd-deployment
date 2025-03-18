#!/bin/bash

# Step 1: Clone the repository (if not already present)
if [ ! -d "tdd-deployment" ]; then
    echo "Cloning repository..."
    git clone https://github.com/RichterDelaCruz/tdd-deployment.git
    cd tdd-deployment
else
    echo "Repository already exists. Updating..."
    cd tdd-deployment
    git pull origin main  # or your branch name
fi

# Step 2: Check NVIDIA driver version and install compatible PyTorch
echo "Checking NVIDIA driver version..."
nvidia_smi_output=$(nvidia-smi)
driver_version=$(echo "$nvidia_smi_output" | grep "Driver Version" | awk '{print $6}')

# Map driver versions to supported CUDA versions
# Reference: https://docs.nvidia.com/deploy/cuda-compatibility/index.html
declare -A driver_to_cuda=(
    ["570.*"]="12.8" # Based on forward compatibility section
    ["550.*"]="12.4"
    ["535.*"]="12.2" # Though 12.3, 12.4, 12.5, 12.6, 12.8 may work with forward compatibility packages
    ["525.*"]="12.0" # Minimum for CUDA 12.x family, also supports CUDA 11.x
    ["520.*"]="11.8"
    ["515.*"]="11.7"
    ["510.*"]="11.6"
    ["470.*"]="11.4"
    ["460.*"]="11.2"
    ["450.*"]="11.0" # Minimum for CUDA 11.x family
    ["440.*"]="10.2"
    ["418.*"]="10.1"
    ["410.*"]="10.0"
    # Add more mappings as needed, but older versions might have limited support
)

# Determine the supported CUDA version
supported_cuda=""
for driver_pattern in "${!driver_to_cuda[@]}"; do
    if [[ "$driver_version" == $driver_pattern ]]; then
        supported_cuda="${driver_to_cuda[$driver_pattern]}"
        break
    fi
done

if [ -z "$supported_cuda" ]; then
    echo "Error: Unsupported NVIDIA driver version $driver_version."
    echo "Please upgrade your NVIDIA driver."
    exit 1
fi

echo "NVIDIA driver version $driver_version supports CUDA $supported_cuda."

# Step 3: Install compatible PyTorch version
echo "Installing PyTorch compatible with CUDA $supported_cuda..."
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu${supported_cuda//./}

# Step 4: Install other dependencies
echo "Installing other dependencies..."
pip install -r requirements.txt

# Step 5: Download the model (if not already present)
echo "Downloading the model..."
python -c "
from transformers import AutoModelForCausalLM, AutoTokenizer
model_name = 'richterdc/deepseek-coder-finetuned-tdd'
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(model_name, device_map='auto', torch_dtype='auto')
print('Model downloaded successfully!')
"

# Step 6: Start the server
echo "Starting server with torchrun and gunicorn..."
torchrun --nproc_per_node=1 $(which gunicorn) -w 1 -b 0.0.0.0:8000 generate-test:app
