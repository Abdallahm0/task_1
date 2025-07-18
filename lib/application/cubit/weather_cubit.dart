import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/current_weather_model.dart';
import '../../domain/repositories/weather_repository.dart';
import 'weather_state.dart';

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
    emit(WeatherLoading());
    try {
      final weather = await repository.getCurrentWeather(lat, lon);
      final forecastTemp = await repository.getForecastTempC(lat, lon, date);
      emit(
        WeatherLoaded(
          currentWeather: weather,
          forecastTempC: forecastTemp,
          selectedDate: date,
        ),
      );
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }
}
