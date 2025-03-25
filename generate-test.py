from flask import Flask, request, jsonify
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch
import os

app = Flask(__name__)
model_name = "richterdc/deepseek-coder-finetuned-tdd"  # Your Hugging Face model

# Load model and tokenizer
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    device_map="auto",  # Auto-use GPU
    torch_dtype=torch.float16  # Use FP16 for faster inference
)

@app.route("/generate", methods=["POST"])
def generate():
    input_text = request.json.get("input_text", "")
    temperature = request.json.get("temperature", 1.5)  # Default to 1.5 if not provided

    inputs = tokenizer(input_text, return_tensors="pt").to(model.device)
    outputs = model.generate(
        **inputs, 
        max_new_tokens=700,
        temperature=temperature,  # Adjusts randomness
        top_p=0.9  # (Optional) Adds nucleus sampling for more variety
    )

    # Remove input prompt from the generated output
    generated_tokens = outputs[0][inputs["input_ids"].shape[1]:]  # Slice out new tokens
    result = tokenizer.decode(generated_tokens, skip_special_tokens=True)

    return jsonify({"result": result})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
