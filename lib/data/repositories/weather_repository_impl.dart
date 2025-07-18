import '../../domain/repositories/weather_repository.dart';
import '../models/current_weather_model.dart';
import '../models/forecast_weather.dart';
import '../weather_api.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  @override
  Future<CurrentWeatherModel> getCurrentWeather(double lat, double lon) {
    return WeatherApi.fetchWeather(lat: lat, lon: lon);
  }

  @override
  Future<double?> getForecastTempC(double lat, double lon, DateTime date) {
    return WeatherApi.fetchForecastTempC(lat: lat, lon: lon, date: date);
  }
}
