import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/current_weather_model.dart';
import '../../domain/repositories/weather_repository.dart';
import 'weather_state.dart';
import '../../data/feature_mapper.dart';
import '../../data/models/prediction_result.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final WeatherRepository repository;
  WeatherCubit(this.repository) : super(WeatherInitial());

  Future<void> loadCurrentWeather(double lat, double lon) async {
    emit(WeatherLoading());
    try {
      final weather = await repository.getCurrentWeather(lat, lon);
      emit(WeatherLoaded(currentWeather: weather));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  Future<void> loadForecast(double lat, double lon, DateTime date) async {
    print('loadForecast called with lat: $lat, lon: $lon, date: $date');
    final prevState = state;
    if (prevState is WeatherLoaded || prevState is WeatherRefreshing) {
      final prevWeather = prevState is WeatherLoaded
          ? prevState.currentWeather
          : (prevState as WeatherRefreshing).currentWeather;
      final prevDate = prevState is WeatherLoaded
          ? prevState.selectedDate
          : (prevState as WeatherRefreshing).selectedDate;
      final prevPrediction = prevState is WeatherLoaded
          ? prevState.predictionResult
          : (prevState as WeatherRefreshing).predictionResult;
      emit(
        WeatherRefreshing(
          currentWeather: prevWeather,
          selectedDate: prevDate,
          predictionResult: prevPrediction,
        ),
      );
    } else {
      emit(WeatherLoading());
    }
    try {
      final today = DateTime.now();
      final isToday =
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      CurrentWeatherModel weather;
      if (isToday) {
        weather = await repository.getCurrentWeather(lat, lon);
        print(
          'Fetched current weather: tempC=${weather.current.tempC}, humidity=${weather.current.humidity}, windKph=${weather.current.windKph}',
        );
      } else {
        final forecast = await repository.getForecastWeather(lat, lon, date);
        if (forecast == null)
          throw Exception('No forecast data available for selected date');
        weather = forecast;
        print(
          'Fetched forecast weather: tempC=${weather.current.tempC}, humidity=${weather.current.humidity}, windKph=${weather.current.windKph}',
        );
      }
      emit(WeatherLoaded(currentWeather: weather, selectedDate: date));
    } catch (e) {
      print('Error in loadForecast: $e');
      emit(WeatherError(e.toString()));
    }
  }

  Future<void> predictTrainingSuitability(CurrentWeatherModel weather) async {
    emit(PredictionLoading());
    try {
      final features = FeatureMapper.mapWeatherToFeatures(weather);
      final result = await repository.predictTrainingSuitability(features);
      emit(PredictionLoaded(result, weather));
    } catch (e) {
      emit(PredictionError(e.toString()));
    }
  }
}
