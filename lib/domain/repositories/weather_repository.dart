import '../../data/models/current_weather_model.dart';

abstract class WeatherRepository {
  Future<CurrentWeatherModel> getCurrentWeather(double lat, double lon);
  Future<double?> getForecastTempC(double lat, double lon, DateTime date);
}
