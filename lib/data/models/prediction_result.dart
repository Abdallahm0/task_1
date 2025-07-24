class PredictionResult {
  final bool isSuitable;
  final String? message;

  PredictionResult({required this.isSuitable, this.message});

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    // Handle both list and single value responses
    dynamic prediction = json['prediction'];
    bool isSuitable;

    if (prediction is List) {
      // If prediction is a list, take the first element
      isSuitable =
          prediction.isNotEmpty &&
          (prediction[0] == 1 || prediction[0] == true);
    } else {
      // If prediction is a single value
      isSuitable = prediction == 1 || prediction == true;
    }

    return PredictionResult(isSuitable: isSuitable, message: json['message']);
  }
}
