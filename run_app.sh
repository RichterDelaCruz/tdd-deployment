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

# Step 2: Check NVIDIA driver version and determine CUDA compatibility
echo "Checking NVIDIA driver version..."
nvidia_smi_output=$(nvidia-smi)
driver_version=$(echo "$nvidia_smi_output" | grep -oP "Driver Version: \K[0-9.]+")

# Map driver versions to supported CUDA versions
declare -A driver_to_cuda=(
    ["570"]="12.8"
    ["550"]="12.4"
    ["535"]="12.2"
    ["525"]="12.0"
    ["520"]="11.8"
    ["515"]="11.7"
    ["510"]="11.6"
    ["470"]="11.4"
    ["460"]="11.2"
    ["450"]="11.0"
    ["440"]="10.2"
    ["418"]="10.1"
    ["410"]="10.0"
)

# Extract the major driver version (e.g., 535.123 → 535)
driver_major=$(echo "$driver_version" | cut -d'.' -f1)

# Determine CUDA compatibility
supported_cuda=${driver_to_cuda[$driver_major]}

if [ -z "$supported_cuda" ]; then
    echo "Error: Unsupported NVIDIA driver version $driver_version."
    echo "Please upgrade your NVIDIA driver."
    exit 1
fi

echo "NVIDIA driver version $driver_version supports CUDA $supported_cuda."

# Step 3: Install compatible PyTorch version
echo "Installing PyTorch for CUDA $supported_cuda..."
if [[ "$supported_cuda" == "12.8" || "$supported_cuda" == "12.4" || "$supported_cuda" == "12.2" || "$supported_cuda" == "12.0" ]]; then
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
elif [[ "$supported_cuda" == "11.8" || "$supported_cuda" == "11.7" || "$supported_cuda" == "11.6" ]]; then
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
else
    echo "Error: No compatible PyTorch version found for CUDA $supported_cuda."
    exit 1
fi

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
$(which gunicorn) -w 1 -b 0.0.0.0:8000 generate-test:app
