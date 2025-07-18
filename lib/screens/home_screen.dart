import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:geolocator/geolocator.dart';
import '../application/cubit/weather_cubit.dart';
import '../application/cubit/weather_state.dart';
import '../data/repositories/weather_repository_impl.dart';
import '../domain/repositories/weather_repository.dart';

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
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            if (state is WeatherLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is WeatherError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is WeatherLoaded) {
              final weather = state.currentWeather;
              final forecastTemp = state.forecastTempC;
              final selectedDate = state.selectedDate ?? _selectedDate;
              return Scaffold(
                body: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.indigo, // Fill background
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? constraints.maxWidth * 0.2 : 8.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(isWide ? 32 : 12),
                                  color: Colors.indigo,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                weather.location.name,
                                                style: TextStyle(
                                                  fontSize: isWide ? 32 : 22,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                weather.location.localtime,
                                                style: TextStyle(
                                                  fontSize: isWide ? 20 : 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                FirebaseAuth
                                                        .instance
                                                        .currentUser
                                                        ?.email ??
                                                    'Not logged in',
                                                style: TextStyle(
                                                  fontSize: isWide ? 16 : 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.location_on,
                                              color: Colors.white,
                                              size: isWide ? 36 : 24,
                                            ),
                                            onPressed: () async {
                                              try {
                                                Position pos =
                                                    await _determinePosition();
                                                context
                                                    .read<WeatherCubit>()
                                                    .loadCurrentWeather(
                                                      pos.latitude,
                                                      pos.longitude,
                                                    );
                                              } catch (e) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Location error: $e',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: isWide ? 40 : 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Transform.scale(
                                            scale: isWide ? 2.0 : 1.6,
                                            child: Image.network(
                                              'https:${weather.current.condition.icon}',
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Icon(
                                                    Icons.cloud,
                                                    size: isWide ? 120 : 80,
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          ),
                                          SizedBox(width: isWide ? 32 : 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                weather.current.tempC
                                                    .toStringAsFixed(1),
                                                style: TextStyle(
                                                  fontSize: isWide ? 90 : 65,
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                "°C",
                                                style: TextStyle(
                                                  fontSize: isWide ? 40 : 30,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                weather.current.condition.text,
                                                style: TextStyle(
                                                  fontSize: isWide ? 28 : 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                "Last updated:  ${weather.current.lastUpdated}",
                                                style: TextStyle(
                                                  fontSize: isWide ? 18 : 15,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: isWide ? 32 : 20),
                                      TableCalendar(
                                        firstDay: DateTime.now().subtract(
                                          Duration(days: 365),
                                        ),
                                        lastDay: DateTime.now().add(
                                          Duration(days: 365),
                                        ),
                                        focusedDay: _focusedDay,
                                        selectedDayPredicate: (day) =>
                                            isSameDay(selectedDate, day),
                                        onDaySelected:
                                            (selectedDay, focusedDay) async {
                                              setState(() {
                                                _selectedDate = selectedDay;
                                                _focusedDay = focusedDay;
                                              });
                                              context
                                                  .read<WeatherCubit>()
                                                  .loadForecast(
                                                    weather.location.lat,
                                                    weather.location.lon,
                                                    selectedDay,
                                                  );
                                            },
                                        headerVisible: true,
                                        headerStyle: HeaderStyle(
                                          formatButtonVisible: false,
                                        ),
                                        calendarFormat: CalendarFormat.month,
                                        calendarStyle: CalendarStyle(
                                          todayDecoration: BoxDecoration(
                                            color: Colors.indigo,
                                            shape: BoxShape.circle,
                                          ),
                                          selectedDecoration: BoxDecoration(
                                            color: Colors.deepPurple,
                                            shape: BoxShape.circle,
                                          ),
                                          selectedTextStyle: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      if (selectedDate != null &&
                                          forecastTemp != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 12.0,
                                          ),
                                          child: Text(
                                            'Expected temperature on ${selectedDate!.toLocal().toString().split(' ')[0]}: ${forecastTemp!.toStringAsFixed(1)} °C',
                                            style: TextStyle(
                                              fontSize: isWide ? 22 : 18,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _InfoCard(
                                        label: "Region",
                                        value:
                                            weather.location.region.isNotEmpty
                                            ? weather.location.region
                                            : "N/A",
                                        icon: Icons.map,
                                        isWide: isWide,
                                      ),
                                      _InfoCard(
                                        label: "Country",
                                        value: weather.location.country,
                                        icon: Icons.flag,
                                        isWide: isWide,
                                      ),
                                      _InfoCard(
                                        label: "Lat/Lon",
                                        value:
                                            "${weather.location.lat.toStringAsFixed(2)}, ${weather.location.lon.toStringAsFixed(2)}",
                                        icon: Icons.location_searching,
                                        isWide: isWide,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
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

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isWide;
  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.indigo,
      ),
      padding: EdgeInsets.all(isWide ? 20 : 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.all(3.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(isWide ? 14.0 : 10.0),
              child: Icon(icon, color: Colors.indigo, size: isWide ? 32 : 24),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3.0),
            child: Text(
              label,
              style: TextStyle(
                fontSize: isWide ? 18 : 15,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3.0),
            child: Text(
              value,
              style: TextStyle(
                fontSize: isWide ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
