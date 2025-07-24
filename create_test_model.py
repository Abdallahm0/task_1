import numpy as np
from sklearn.ensemble import RandomForestClassifier
import pickle

# Features: [rainy, sunny, temp_hot, temp_mild, humidity_normal]
data = []
labels = []

for temp in range(10, 41):  # Temperatures from 10°C to 40°C
    for rain in [0, 1]:
        for sun in [0, 1]:
            for humidity in [0, 1]:
                temp_hot = 1 if temp >= 30 else 0
                temp_mild = 1 if 20 <= temp < 30 else 0
                features = [rain, sun, temp_hot, temp_mild, humidity]
                # Label: 0 if temp_hot else 1
                label = 0 if temp_hot else 1
                data.append(features)
                labels.append(label)

X = np.array(data)
y = np.array(labels)

# Train the model
clf = RandomForestClassifier(n_estimators=100, random_state=42)
clf.fit(X, y)

# Save the model
with open('random_forest_model.pkl', 'wb') as f:
    pickle.dump(clf, f)

print("Model trained and saved as random_forest_model.pkl") 