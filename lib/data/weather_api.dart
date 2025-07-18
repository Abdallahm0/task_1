import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/current_weather_model.dart';
import 'models/forecast_weather.dart';

class WeatherApi {
  static const String apiKey =
      '61333eb8c32f4be48ad182041251707'; // Replace with your actual WeatherAPI.com key
  static const String baseUrl = 'https://api.weatherapi.com/v1/current.json';
  static const String forecastUrl =
      'https://api.weatherapi.com/v1/forecast.json';

  static Future<CurrentWeatherModel> fetchWeather({
    required double lat,
    required double lon,
  }) async {
    final url = '$baseUrl?key=$apiKey&q=$lat,$lon&aqi=no';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return CurrentWeatherModel.fromJson(json.decode(response.body));
    } else {
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      throw Exception('Failed to load weather data');
    }
  }

  static Future<double?> fetchForecastTempC({
    required double lat,
    required double lon,
    required DateTime date,
  }) async {
    final dateString =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final url =
        '$forecastUrl?key=$apiKey&q=$lat,$lon&dt=$dateString&aqi=no&alerts=no';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // The forecast day is in data['forecast']['forecastday'][0]['day']['avgtemp_c']
      final forecastDay = data['forecast']?['forecastday']?[0]?['day'];
      if (forecastDay != null && forecastDay['avgtemp_c'] != null) {
        return (forecastDay['avgtemp_c'] as num).toDouble();
      }
      return null;
    } else {
      print('Forecast Status: ${response.statusCode}');
      print('Forecast Body: ${response.body}');
      throw Exception('Failed to load forecast data');
    }
  }
}
