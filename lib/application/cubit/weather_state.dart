import '../../data/models/current_weather_model.dart';
import '../../data/models/prediction_result.dart';

abstract class WeatherState {}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final CurrentWeatherModel currentWeather;
  final double? forecastTempC;
  final DateTime? selectedDate;
  final PredictionResult? predictionResult;
  WeatherLoaded({
    required this.currentWeather,
    this.forecastTempC,
    this.selectedDate,
    this.predictionResult,
  });
}

class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message);
}

class WeatherRefreshing extends WeatherState {
  final CurrentWeatherModel currentWeather;
  final DateTime? selectedDate;
  final PredictionResult? predictionResult;
  WeatherRefreshing({
    required this.currentWeather,
    this.selectedDate,
    this.predictionResult,
  });
}

class PredictionLoading extends WeatherState {}

class PredictionLoaded extends WeatherState {
  final PredictionResult result;
  final CurrentWeatherModel currentWeather;
  PredictionLoaded(this.result, this.currentWeather);
}

class PredictionError extends WeatherState {
  final String message;
  PredictionError(this.message);
}
