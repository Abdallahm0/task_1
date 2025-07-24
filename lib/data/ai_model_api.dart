import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/prediction_result.dart';

class AIModelApi {
  static const String baseUrl = 'http://192.168.1.9:5001/predict';

  static Future<PredictionResult> predictTrainingSuitability(
    List<int> features,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'features': features}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PredictionResult.fromJson(data);
      } else {
        throw Exception(
          'Server returned status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      print('Exception in AIModelApi: $e');
      throw Exception('Failed to get prediction from AI model: $e');
    }
  }
}
