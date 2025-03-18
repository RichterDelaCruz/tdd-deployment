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

# Step 2: Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# Step 3: Download the model (if not already present)
echo "Downloading the model..."
python -c "
from transformers import AutoModelForCausalLM, AutoTokenizer
model_name = 'richterdc/deepseek-coder-finetuned-tdd'
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(model_name, device_map='auto', torch_dtype='auto')
print('Model downloaded successfully!')
"

# Step 4: Start the server
echo "Starting server with torchrun and gunicorn..."
torchrun --nproc_per_node=1 gunicorn -w 1 -b 0.0.0.0:8000 generate-test:app