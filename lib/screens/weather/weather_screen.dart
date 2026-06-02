import 'package:flutter/material.dart';
import 'package:aerodry_app/screens/dashboard_screen.dart';
import 'package:aerodry_app/services/weather_service.dart';
import 'package:aerodry_app/constants/app_state.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherData? _weather;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final location = deviceList.isNotEmpty
          ? deviceList[activeDeviceIndex].location
          : 'Tangerang';
      final data = await WeatherService.fetchForLocation(location);
      if (mounted) {
        setState(() {
          _weather = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  String get _activeCity {
    if (deviceList.isEmpty) return 'Unknown';
    return WeatherService.extractCityName(
        deviceList[activeDeviceIndex].location);
  }

  String _dayName(DateTime d) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return days[d.weekday - 1];
  }

  String _dateLabel(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 24),
          child: Column(
            children: [
              // ── App Bar ──────────────────────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF4C75D8),
                      size: 22,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Weather',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0C3B77),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),

              const SizedBox(height: 22),

              // ── Main Weather Card ─────────────────────────────────────────
              Container(
                height: 290,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4E6EC4), Color(0xFF74C0F3)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : _error != null
                        ? _ErrorBody(error: _error!, onRetry: _fetchWeather)
                        : _WeatherCardBody(
                            weather: _weather!,
                            cityName: _activeCity,
                          ),
              ),

              const SizedBox(height: 22),

              // ── 7-Day Forecast ────────────────────────────────────────────
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                const SizedBox.shrink()
              else
                ...(_weather!.daily.map((day) {
                  final code = day.weatherCode;
                  final wind = _weather!.current.windSpeed;
                  return _ForecastCard(
                    day: _dayName(day.date),
                    date: _dateLabel(day.date),
                    status: WeatherCodeHelper.label(code, windSpeed: wind),
                    percent: '${day.precipitationProbability}%',
                    temp: '${day.maxTemp}°',
                    imagePath: WeatherCodeHelper.assetPath(code, windSpeed: wind),
                    color: Color(WeatherCodeHelper.colorValue(code, windSpeed: wind)),
                  );
                })),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Weather Card Body ────────────────────────────────────────────────────────

class _WeatherCardBody extends StatelessWidget {
  final WeatherData weather;
  final String cityName;

  const _WeatherCardBody({required this.weather, required this.cityName});

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    final mainAsset =
        WeatherCodeHelper.mainAsset(current.weatherCode, windSpeed: current.windSpeed);

    return Column(
      children: [
        const SizedBox(height: 13),

        Text(
          cityName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),

        Text(
          '${current.temperature}°',
          style: const TextStyle(
            fontSize: 35,
            height: 0.95,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 8),

        Image.asset(
          mainAsset,
          width: 90,
          height: 90,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 5),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _WeatherInfo(
              icon: Icons.water_drop,
              title: 'Humidity',
              value: '${current.humidity}%',
            ),
            _WeatherInfo(
              icon: Icons.sunny,
              title: 'UV Index',
              value: current.uvIndex.toStringAsFixed(1),
            ),
            _WeatherInfo(
              icon: Icons.air,
              title: 'Wind Speed',
              value: '${current.windSpeed.round()}km/h',
            ),
          ],
        ),

        const SizedBox(height: 10),

        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < weather.hourly.length; i++) ...[
                if (i > 0) const SizedBox(width: 9),
                _MiniWeather(
                  hourly: weather.hourly[i],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Error body ───────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorBody({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.white70, size: 36),
          const SizedBox(height: 8),
          const Text(
            'Failed to load weather',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _WeatherInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _WeatherInfo({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 25, color: Colors.white70),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                height: 0.9,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniWeather extends StatelessWidget {
  final HourlyWeather hourly;

  const _MiniWeather({required this.hourly});

  @override
  Widget build(BuildContext context) {
    final icon = WeatherCodeHelper.hourlyIcon(hourly.weatherCode, hourly.windSpeed);
    final iconColor = WeatherCodeHelper.hourlyIconColor(hourly.weatherCode, hourly.windSpeed);
    final isNow = hourly.hour == 'Now';

    return Container(
      width: 40,
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hourly.hour,
            style: TextStyle(
              fontSize: isNow ? 10.5 : 11.0,
              fontWeight: isNow ? FontWeight.w800 : FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            icon,
            size: 19,
            color: iconColor,
          ),
          const SizedBox(height: 4),
          Text(
            '${hourly.temperature}°',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Forecast Card ────────────────────────────────────────────────────────────

class _ForecastCard extends StatelessWidget {
  final String day;
  final String date;
  final String status;
  final String percent;
  final String temp;
  final String imagePath;
  final Color color;

  const _ForecastCard({
    required this.day,
    required this.date,
    required this.status,
    required this.percent,
    required this.temp,
    required this.imagePath,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 61,
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Center(
              child: SizedBox(
                width: 52,
                height: 52,
                child: Center(
                  child: Image.asset(
                    imagePath,
                    width: imagePath.contains('sun') ? 40 : 48,
                    height: imagePath.contains('sun') ? 40 : 48,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            width: 82,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Icon(
                      Icons.water_drop_outlined,
                      size: 13,
                      color: color,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      percent,
                      style: TextStyle(
                        fontSize: 13,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Transform.translate(
            offset: const Offset(-6, 0),
            child: Text(
              temp,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}