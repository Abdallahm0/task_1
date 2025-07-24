import '../../data/models/current_weather_model.dart';
import '../../data/models/prediction_result.dart';

abstract class WeatherRepository {
  Future<CurrentWeatherModel> getCurrentWeather(double lat, double lon);
  Future<double?> getForecastTempC(double lat, double lon, DateTime date);
  Future<PredictionResult> predictTrainingSuitability(List<int> features);
  Future<CurrentWeatherModel?> getForecastWeather(
    double lat,
    double lon,
    DateTime date,
  );
}
