import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:geolocator/geolocator.dart';
import '../application/cubit/weather_cubit.dart';
import '../application/cubit/weather_state.dart';
import '../data/repositories/weather_repository_impl.dart';
import '../domain/repositories/weather_repository.dart';
import '../data/models/prediction_result.dart';
import '../data/models/current_weather_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate = DateTime.now();
  double _defaultLat = 51.5074;
  double _defaultLon = -0.1278;

  @override
  void initState() {
    super.initState();
    // Load initial weather
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherCubit>().loadCurrentWeather(_defaultLat, _defaultLon);
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    // Automatically trigger prediction when weather data changes and predictionResult is null
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        if (state is WeatherLoaded && state.predictionResult == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<WeatherCubit>().predictTrainingSuitability(
              state.currentWeather,
            );
          });
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            if (state is WeatherLoading || state is PredictionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is WeatherError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is WeatherRefreshing ||
                state is WeatherLoaded ||
                state is PredictionLoaded) {
              final currentWeather = (state is WeatherLoaded)
                  ? state.currentWeather
                  : (state is WeatherRefreshing)
                  ? (state as WeatherRefreshing).currentWeather
                  : (state is PredictionLoaded)
                  ? (state as PredictionLoaded).currentWeather
                  : null;
              final predictionResult = state is WeatherLoaded
                  ? state.predictionResult
                  : (state is WeatherRefreshing)
                  ? (state as WeatherRefreshing).predictionResult
                  : (state is PredictionLoaded)
                  ? (state as PredictionLoaded).result
                  : null;
              final forecastTemp = state is WeatherLoaded
                  ? state.forecastTempC
                  : null;
              final selectedDate = state is WeatherLoaded
                  ? (state.selectedDate ?? _selectedDate)
                  : (state is WeatherRefreshing)
                  ? (state as WeatherRefreshing).selectedDate ?? _selectedDate
                  : _selectedDate;
              final userEmail =
                  FirebaseAuth.instance.currentUser?.email ?? 'Not logged in';
              return Scaffold(
                backgroundColor: Colors.indigo[900],
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state is WeatherRefreshing)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.indigo[700],
                                color: Colors.orange,
                              ),
                            ),
                          // Calendar at the top
                          TableCalendar(
                            firstDay: DateTime.now().subtract(
                              Duration(days: 365),
                            ),
                            lastDay: DateTime.now().add(Duration(days: 365)),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) =>
                                isSameDay(selectedDate, day),
                            onDaySelected: (selectedDay, focusedDay) async {
                              setState(() {
                                _selectedDate = selectedDay;
                                _focusedDay = focusedDay;
                              });
                              context.read<WeatherCubit>().loadForecast(
                                currentWeather?.location.lat ?? _defaultLat,
                                currentWeather?.location.lon ?? _defaultLon,
                                selectedDay,
                              );
                            },
                            headerVisible: false,
                            calendarFormat: CalendarFormat.week,
                            daysOfWeekVisible: true,
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: Colors.deepPurple,
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              selectedTextStyle: TextStyle(color: Colors.white),
                              weekendTextStyle: TextStyle(
                                color: Colors.white70,
                              ),
                              defaultTextStyle: TextStyle(color: Colors.white),
                              outsideTextStyle: TextStyle(
                                color: Colors.white38,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          // User info, location, date/time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentWeather?.location.name ??
                                        'Loading...',
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    currentWeather?.location.localtime ??
                                        'Loading...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    userEmail,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                onPressed: () async {
                                  try {
                                    Position pos = await _determinePosition();
                                    context
                                        .read<WeatherCubit>()
                                        .loadCurrentWeather(
                                          pos.latitude,
                                          pos.longitude,
                                        );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Location error: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 18),
                          // Weather info grid
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32),
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width - 40) /
                                      2, // 2 columns, adjust for padding/margin
                                  child: _WeatherInfoCard(
                                    icon: Icons.thermostat,
                                    label: 'Temperature',
                                    value: currentWeather != null
                                        ? '${currentWeather.current.tempC.toStringAsFixed(1)}°C'
                                        : '-',
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width - 40) /
                                      2, // 2 columns, adjust for padding/margin
                                  child: _WeatherInfoCard(
                                    icon: Icons.air,
                                    label: 'Wind Speed',
                                    value: currentWeather != null
                                        ? '${(currentWeather.current.windKph / 3.6).toStringAsFixed(1)} m/s'
                                        : '-',
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width - 40) /
                                      2, // 2 columns, adjust for padding/margin
                                  child: _WeatherInfoCard(
                                    icon: Icons.cloud,
                                    label: 'Cloud Cover',
                                    value: currentWeather != null
                                        ? '${currentWeather.current.cloud}%'
                                        : '-',
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width - 40) /
                                      2, // 2 columns, adjust for padding/margin
                                  child: _WeatherInfoCard(
                                    icon: Icons.opacity,
                                    label: 'Humidity',
                                    value: currentWeather != null
                                        ? '${currentWeather.current.humidity}%'
                                        : '-',
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width - 40) /
                                      2, // 2 columns, adjust for padding/margin
                                  child: _WeatherInfoCard(
                                    icon: Icons.grain,
                                    label: 'Precipitation',
                                    value: currentWeather != null
                                        ? '${currentWeather.current.precipMm.toStringAsFixed(1)} mm'
                                        : '-',
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width - 40) /
                                      2, // 2 columns, adjust for padding/margin
                                  child: _WeatherInfoCard(
                                    icon: Icons.wb_sunny,
                                    label: 'UV Index',
                                    value: currentWeather != null
                                        ? '${currentWeather.current.uv}'
                                        : '-',
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 40),
                                  child: SizedBox(
                                    width:
                                        (MediaQuery.of(context).size.width -
                                            40) /
                                        2, // 2 columns, adjust for padding/margin
                                    child: _WeatherInfoCard(
                                      icon: Icons.sports_tennis,
                                      label: 'Tennis Status',
                                      value:
                                          (predictionResult != null &&
                                              predictionResult.isSuitable)
                                          ? 'Recommended'
                                          : 'Not Recommended',
                                      valueColor:
                                          (predictionResult != null &&
                                              predictionResult.isSuitable)
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return const Center(child: Text('No weather data available'));
            }
          },
        );
      },
    );
  }
}

class _WeatherInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _WeatherInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.indigo[800],
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          SizedBox(height: 12),
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 15)),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
