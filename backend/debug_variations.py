import requests
import json
import sys

# Force UTF-8 for stdout
sys.stdout.reconfigure(encoding='utf-8')

url = "http://localhost:8000/generate_variations"
# Using English to avoid client-side terminal encoding issues for now
payload = {
    "product_name": "Liquid Soap",
    "description": "Deep cleaning",
    "language": "en"
}

try:
    print(f"Sending request to {url} with payload: {payload}")
    response = requests.post(url, json=payload)
    print(f"Status Code: {response.status_code}")
    print("Response Body:")
    print(response.text)
except Exception as e:
    print(f"Error: {e}")
