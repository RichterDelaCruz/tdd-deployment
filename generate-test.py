from flask import Flask, request, jsonify
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch
from threading import Lock

app = Flask(__name__)
model_name = "deepseek-ai/deepseek-coder-1.3b-instruct"

# Stronger instruction to enforce only one test case
INSTRUCTION_TEMPLATE = """<<INSTRUCTION>>
You are a TDD expert. Your task is to generate **exactly one** test case to verify correctness.

**Response format:**
- Start with "Test case: "
- Provide the reason after "Reason: "
- Show an example with "Example: "

**Rules:**
- Only **one** test case per response.
- Do **not** output multiple test cases.
- Do **not** include code formatting (no markdown, no JSON, no backticks).
<</INSTRUCTION>>

"""

try:
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForCausalLM.from_pretrained(
        model_name,
        device_map="auto",
        torch_dtype=torch.float16
    )
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token
except Exception as e:
    raise RuntimeError(f"Model loading failed: {str(e)}")

model_lock = Lock()

@app.route("/generate", methods=["POST"])
def generate():
    try:
        data = request.get_json()
        input_text = data.get("input_text", "")
        temperature = min(max(float(data.get("temperature", 0.7)), 0.1), 2.0)

        # Build prompt with strict instruction
        full_prompt = INSTRUCTION_TEMPLATE + input_text.split("Task:")[-1].strip()
        
        with model_lock:
            inputs = tokenizer(full_prompt, return_tensors="pt", truncation=True, max_length=2048).to(model.device)
            outputs = model.generate(
                **inputs,
                max_new_tokens=min(int(data.get("max_tokens", 150)), 150),  # Reduce token count
                temperature=temperature,
                top_p=0.9,
                do_sample=True,
                pad_token_id=tokenizer.pad_token_id,
                eos_token_id=tokenizer.eos_token_id
            )

            # Extract only the generated part
            full_output = tokenizer.decode(outputs[0], skip_special_tokens=True)
            clean_output = full_output.split("<</INSTRUCTION>>")[-1].strip()

            # Ensure only one test case is extracted
            lines = clean_output.split("\n")
            extracted_test_case = []
            for line in lines:
                if "Test case:" in line or "Reason:" in line or "Example:" in line:
                    extracted_test_case.append(line.strip())
                if len(extracted_test_case) >= 3:  # Stop at the first full test case
                    break
            
            # Final result (ensures only one test case)
            clean_output = " | ".join(extracted_test_case[:3])  # Limit to just one test case

        return jsonify({"result": clean_output})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, threaded=True)
