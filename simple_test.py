import urllib.request
import json

# Test the Flask API
url = "http://192.168.1.9:5001/predict"
data = {"features": [0, 1, 0, 1, 1]}  # Sunny, mild, normal humidity

try:
    # Convert data to JSON
    json_data = json.dumps(data).encode('utf-8')
    
    # Create request
    req = urllib.request.Request(url, data=json_data, headers={'Content-Type': 'application/json'})
    
    # Send request
    with urllib.request.urlopen(req) as response:
        result = response.read().decode('utf-8')
        print(f"Status Code: {response.getcode()}")
        print(f"Response: {result}")
        
except Exception as e:
    print(f"Exception: {e}") 