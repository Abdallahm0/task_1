import '../../data/models/current_weather_model.dart';

abstract class WeatherState {}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final CurrentWeatherModel currentWeather;
  final double? forecastTempC;
  final DateTime? selectedDate;
  WeatherLoaded({
    required this.currentWeather,
    this.forecastTempC,
    this.selectedDate,
  });
}

class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message);
}
