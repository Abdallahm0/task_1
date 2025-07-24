import 'models/current_weather_model.dart';

class FeatureMapper {
  // Example mapping: adjust as needed to match your AI model's expected input order
  static List<int> mapWeatherToFeatures(CurrentWeatherModel weather) {
    final outlook = weather.current.condition.text.toLowerCase();
    final tempC = weather.current.tempC;
    final humidity = weather.current.humidity;
    // Example: outlook is rainy, outlook is sunny, temperature is hot, temperature is mild, humidity is normal
    return [
      outlook.contains('rain') ? 1 : 0, // outlook is rainy
      outlook.contains('sun') ? 1 : 0, // outlook is sunny
      tempC >= 30 ? 1 : 0, // temperature is hot
      (tempC >= 20 && tempC < 30) ? 1 : 0, // temperature is mild
      (humidity >= 40 && humidity <= 70)
          ? 1
          : 0, // humidity is normal (example range)
    ];
  }
}
