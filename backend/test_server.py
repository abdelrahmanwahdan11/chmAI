import requests
import json

print("Testing if server is running and checking model name...")
print("=" * 60)

# Test 1: Check if server is alive
try:
    response = requests.get("http://localhost:8000/")
    print(f"[OK] Server is RUNNING")
    print(f"  Response: {response.json()}")
except Exception as e:
    print(f"[ERROR] Server is NOT running: {e}")
    print("\nPlease start the server first: python server.py")
    exit(1)

print("\n" + "=" * 60)
print("Testing /generate_variations endpoint...")
print("=" * 60)

# Test 2: Try generate_variations
url = "http://localhost:8000/generate_variations"
payload = {
    "product_name": "Test Soap",
    "description": "Testing",
    "language": "en"
}

try:
    print(f"\nSending request to {url}")
    response = requests.post(url, json=payload, timeout=30)
    print(f"\nStatus Code: {response.status_code}")
    
    if response.status_code == 200:
        print("[SUCCESS] The endpoint is working!")
        data = response.json()
        print(f"\nReceived {len(data.get('variations', []))} variations")
    else:
        print("[ERROR] Error occurred")
        print("\nResponse body:")
        print(response.text)
        
        # Check if it's the old gemini-pro error
        if "gemini-pro" in response.text.lower():
            print("\n[PROBLEM FOUND] Server is still using old 'gemini-pro' model")
            print("   The code changes were not applied to the running server.")
            print("\n   SOLUTION: Stop and restart the server")
        
except Exception as e:
    print(f"[ERROR] Request failed: {e}")
