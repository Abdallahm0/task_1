from flask import Flask, request, jsonify
import pickle
import numpy as np
import warnings
import traceback
warnings.filterwarnings('ignore')

app = Flask(__name__)

# Load the model
file_path = "random_forest_model.pkl"  # Path to the model file
try:
    with open(file_path, 'rb') as file:
        model = pickle.load(file)
    print(f"Model loaded successfully from {file_path}")
    print(f"Model type: {type(model)}")
    
    # Test the model with a simple prediction
    test_features = np.array([[0, 1, 0, 1, 1]])
    test_prediction = model.predict(test_features)
    print(f"Test prediction: {test_prediction}")
    
except Exception as e:
    print(f"Error loading model: {e}")
    print(f"Traceback: {traceback.format_exc()}")
    model = None

# Define a route for the home page
@app.route('/')
def home():
    return "Welcome to the ML Prediction API!"

# Define a test route
@app.route('/test')
def test():
    if model is None:
        return jsonify({'error': 'Model not loaded'}), 500
    
    try:
        test_features = np.array([[0, 1, 0, 1, 1]])
        prediction = model.predict(test_features)
        return jsonify({'test_prediction': prediction.tolist()})
    except Exception as e:
        return jsonify({'error': str(e), 'traceback': traceback.format_exc()}), 500

# Define the prediction route
@app.route('/predict', methods=['POST'])
def predict():
    if model is None:
        return jsonify({'error': 'Model not loaded'}), 500
    
    try:
        data = request.json  # Get the JSON data from the request
        features = data['features']  # Extract the features
        
        # Debug logging
        print(f"Received features: {features}")
        print(f"Features type: {type(features)}")
        print(f"Features length: {len(features)}")

        # Convert to 2D array (since the model expects 2D input)
        features = np.array(features).reshape(1, -1)
        print(f"Reshaped features: {features}")

        # Make the prediction
        prediction = model.predict(features)
        print(f"Model prediction: {prediction}")

        # Return the prediction as JSON
        return jsonify({'prediction': prediction.tolist()})
    except Exception as e:
        print(f"Error during prediction: {e}")
        print(f"Traceback: {traceback.format_exc()}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)