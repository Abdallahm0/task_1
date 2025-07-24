import '../../domain/repositories/weather_repository.dart';
import '../models/current_weather_model.dart';
import '../models/forecast_weather.dart';
import '../weather_api.dart';
import '../ai_model_api.dart';
import '../models/prediction_result.dart';
import '../feature_mapper.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  @override
  Future<CurrentWeatherModel> getCurrentWeather(double lat, double lon) {
    return WeatherApi.fetchWeather(lat: lat, lon: lon);
  }

  @override
  Future<double?> getForecastTempC(double lat, double lon, DateTime date) {
    return WeatherApi.fetchForecastTempC(lat: lat, lon: lon, date: date);
  }

  @override
  Future<PredictionResult> predictTrainingSuitability(List<int> features) {
    return AIModelApi.predictTrainingSuitability(features);
  }

  @override
  Future<CurrentWeatherModel?> getForecastWeather(
    double lat,
    double lon,
    DateTime date,
  ) {
    return WeatherApi.fetchForecastWeather(lat: lat, lon: lon, date: date);
  }
}
