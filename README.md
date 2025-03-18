# TDD Deployment

This repository contains a Flask API for generating test cases using a Hugging Face model fine-tuned for Test-Driven Development (TDD). The API is designed to analyze code and suggest essential test cases.

---

## **Features**
- **Test Case Generation:** Generates test cases based on input code or descriptions.
- **GPU Acceleration:** Uses PyTorch and Hugging Face Transformers for fast inference.
- **Production-Ready:** Deployed with `gunicorn` and `torchrun` for scalability.

---

## **Setup**

### **1. Clone the Repository**
Clone this repository to your workspace:
```bash
git clone https://github.com/RichterDelaCruz/tdd-deployment.git
cd tdd-deployment
```

### **2. Install Dependencies**
Install the required Python packages:
```bash
pip install -r requirements.txt
```

### **3. Run the Application**
Start the Flask API with `torchrun` and `gunicorn`:
```bash
torchrun --nproc_per_node=1 gunicorn -w 1 -b 0.0.0.0:8000 generate-test:app
```

---

## **Usage**

### **Send a Request**
You can test the API using `curl`:
```bash
curl -X POST "http://localhost:8000/generate" \
  -H "Content-Type: application/json" \
  -d '{"input_text": "Write a Python function to add two numbers"}'
```

### **Example Output**
The API will return a response like:
```json
{
  "result": "Here is a Python function to add two numbers:\n\n```python\ndef add_numbers(a, b):\n    return a + b\n```"
}
```

---

## **Files**
- `generate-test.py`: The Flask app for generating test cases.
- `requirements.txt`: List of Python dependencies.
- `prompt.json`: Example input for testing the API.
- `README.md`: This file.

---

## **Deployment on Vast.ai**
1. **SSH into Your Instance:**
   ```bash
   ssh -p <PORT> root@<HOST>
   ```

2. **Clone the Repository:**
   ```bash
   git clone https://github.com/RichterDelaCruz/tdd-deployment.git
   cd tdd-deployment
   ```

3. **Install Dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the App:**
   ```bash
   torchrun --nproc_per_node=1 gunicorn -w 1 -b 0.0.0.0:8000 generate-test:app
   ```

---

## **License**
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
---

### **How to Use the Repository on Vast.ai**

#### **1. SSH into Your Instance**
Use the SSH command provided by Vast.ai to connect to your instance:
```bash
ssh -p <PORT> root@<HOST>
```

#### **2. Clone the Repository**
Clone your GitHub repository:
```bash
git clone https://github.com/RichterDelaCruz/tdd-deployment.git
cd tdd-deployment
```

#### **3. Install Dependencies**
Install the required Python packages:
```bash
pip install -r requirements.txt
```

#### **4. Run the App**
Start the Flask API with `torchrun` and `gunicorn`:
```bash
torchrun --nproc_per_node=1 gunicorn -w 1 -b 0.0.0.0:8000 generate-test:app
```

---

### **Testing the API**
Once the server is running, you can test the API using `curl`:
```bash
curl -X POST "http://localhost:8000/generate" \
  -H "Content-Type: application/json" \
  -d '{"input_text": "Write a Python function to add two numbers"}'
```

---

### **One-Liner for Quick Setup**
If you want to automate everything from scratch (e.g., on a fresh Vast.ai instance), you can use a **one-liner** to:
1. Clone the repository.
2. Install dependencies.
3. Run the app.

#### **One-Liner Command**
```bash
bash <(curl -s https://raw.githubusercontent.com/RichterDelaCruz/tdd-deployment/main/run_app.sh)
```