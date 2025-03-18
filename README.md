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
Clone this repository:
```bash
git clone https://github.com/RichterDelaCruz/tdd-deployment.git
cd tdd-deployment
```

---

## **Running on Local Machine (CPU)**

### **1. Install Dependencies**
Install the required Python packages:
```bash
pip install -r requirements.txt
```

### **2. Run the Application**
Start the Flask API:
```bash
python generate-test.py
```

### **3. Test the API**
Send a request using `curl`:
```bash
curl -X POST "http://localhost:8000/generate" \
  -H "Content-Type: application/json" \
  -d '{"input_text": "Write a Python function to add two numbers"}'
```

---

## **Running on Local Machine but Connected to Remote GPU**

### **1. Set Up Remote GPU Instance**
- Use the following template on Vast.ai:
  - **GPU:** NVIDIA A100 80GB
  - **Disk Space:** At least 20GB (to accommodate the model and dependencies).
  - **CUDA:** Ensure the instance supports CUDA for GPU acceleration.

### **2. SSH into Your Remote Instance**
Use the SSH command provided by Vast.ai:

2.1. Go to your Vast.ai instance dashboard.

2.2. Locate the **SSH Command** for your instance (it looks like a key icon).
![Alt text](images/find-ssh-key.png)

2.3. Click the **Add/Remove SSH Keys** button.
![Alt text](images/click-add-ssh.png)

2.4. Click the **Copy Proxy SSH Command** button.
![Alt text](images/copy-proxy-ssh.png)

### **3. Clone the Repository**
Clone the repository on the remote instance:
```bash
git clone https://github.com/RichterDelaCruz/tdd-deployment.git
cd tdd-deployment
```

### **4. Install Dependencies**
Install the required Python packages:
```bash
pip install -r requirements.txt
```

### **5. Start the Flask API**
Run the Flask API on the remote instance:
```bash
torchrun --nproc_per_node=1 gunicorn -w 1 -b 0.0.0.0:8000 generate-test:app
```

### **6. Set Up SSH Port Forwarding**
On your **local machine**, set up SSH port forwarding to connect to the remote GPU instance:
```bash
ssh -p <PORT> -L 8000:localhost:8000 root@<HOST>
```

### **7. Test the API from Your Local Machine**
Send a request from your local machine:
```bash
curl -X POST "http://localhost:8000/generate" \
  -H "Content-Type: application/json" \
  -d '{"input_text": "Write a Python function to add two numbers"}'
```

---

## **Running Only on Remote GPU**

### **1. Set Up Remote GPU Instance**
- Use the following template on Vast.ai:
  - **GPU:** NVIDIA A100 80GB
  - **Disk Space:** At least 20GB (to accommodate the model and dependencies).
  - **CUDA:** Ensure the instance supports CUDA for GPU acceleration.

### **2. Clone the Repository**
Clone the repository on the remote instance:
```bash
git clone https://github.com/RichterDelaCruz/tdd-deployment.git
cd tdd-deployment
```

### **3. Install Dependencies**
Install the required Python packages:
```bash
pip install -r requirements.txt
```

### **4. Start the Flask API**
Run the Flask API on the remote instance:
```bash
torchrun --nproc_per_node=1 gunicorn -w 1 -b 0.0.0.0:8000 generate-test:app
```

### **5. Test the API**
Send a request from the remote instance:
```bash
curl -X POST "http://localhost:8000/generate" \
  -H "Content-Type: application/json" \
  -d '{"input_text": "Write a Python function to add two numbers"}'
```

---

## **Testing**

### **1. Example Input**
Use the `prompt.json` file to test the API:
```bash
curl -X POST "http://localhost:8000/generate" \
  -H "Content-Type: application/json" \
  --data-binary @prompt.json
```

### **2. Example Output**
The API will return a response like:
```json
{
  "result": "Test Case: Verify that the `hash_function` in `helpers.py` correctly hashes a password using SHA-256.\nReason: This ensures that passwords are securely hashed and cannot be easily reversed.\nInput: `password123`\nExpected Output: A SHA-256 hash of the input password, e.g., `ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f`."
}
```

---

## **Files**
- `generate-test.py`: The Flask app for generating test cases.
- `requirements.txt`: List of Python dependencies.
- `prompt.json`: Example input for testing the API.
- `README.md`: This file.

---

## **License**
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

### **Key Changes**
1. **Three Scenarios:**
   - **Local Machine (CPU):** No GPU, just local testing.
   - **Local Machine + Remote GPU:** Local machine connects to a remote GPU instance via SSH port forwarding.
   - **Remote GPU Only:** Everything runs on the remote GPU instance.

2. **SSH Port Forwarding:**
   - Added instructions for setting up SSH port forwarding to connect your local machine to the remote GPU instance.

3. **Vast.ai Template:**
   - Clearly specified the recommended GPU (NVIDIA A100 80GB) and disk space requirements.

---

### **One-Liner for Quick Setup on Vast.ai**
If you want to automate everything from scratch on a fresh Vast.ai instance, use this **one-liner**:
```bash
bash <(curl -s https://raw.githubusercontent.com/RichterDelaCruz/tdd-deployment/main/run_app.sh)
```