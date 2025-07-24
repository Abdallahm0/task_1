import requests
import json

# Test the Flask API
url = "http://192.168.1.9:5001/predict"
data = {"features": [0, 1, 0, 1, 1]}  # Sunny, mild, normal humidity

try:
    response = requests.post(url, json=data)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.text}")
    
    if response.status_code == 200:
        result = response.json()
        print(f"Prediction: {result}")
    else:
        print(f"Error: {response.text}")
        
except Exception as e:
    print(f"Exception: {e}") 