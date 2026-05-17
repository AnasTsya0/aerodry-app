import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ─── Data Models ──────────────────────────────────────────────────────────────

class HourlyWeather {
  final String hour; // e.g. "16", "17"
  final int temperature;
  final int weatherCode;
  final double windSpeed;
  final int humidity;
  final double uvIndex;

  const HourlyWeather({
    required this.hour,
    required this.temperature,
    required this.weatherCode,
    required this.windSpeed,
    required this.humidity,
    required this.uvIndex,
  });
}

class DailyWeather {
  final DateTime date;
  final int weatherCode;
  final int maxTemp;
  final int precipitationProbability;

  const DailyWeather({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.precipitationProbability,
  });
}

class WeatherData {
  final String cityName;
  final HourlyWeather current;
  final List<HourlyWeather> hourly; // 6 items: now + next 5 hours
  final List<DailyWeather> daily;   // 7 days

  const WeatherData({
    required this.cityName,
    required this.current,
    required this.hourly,
    required this.daily,
  });
}

// ─── WMO Code Helpers ─────────────────────────────────────────────────────────

class WeatherCodeHelper {
  /// Short label — max ~9 chars so it never overflows the forecast card
  static String label(int code, {double windSpeed = 0}) {
    if (windSpeed >= 30) return 'Windy';
    if (code == 0) return 'Clear';
    if (code <= 2) return 'Pt. Cloudy';
    if (code == 3) return 'Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 55) return 'Drizzle';
    if (code <= 67) return 'Rain';
    if (code <= 77) return 'Snow';
    if (code <= 82) return 'Showers';
    return 'Thunder';
  }

  /// Returns asset path for forecast card image
  static String assetPath(int code, {double windSpeed = 0}) {
    if (windSpeed >= 30) return 'assets/images/windw.png';
    if (code == 0 || code <= 2) return 'assets/images/sunw.png';
    if (code <= 48) return 'assets/images/windw.png';
    if (code >= 51) return 'assets/images/rainw.png';
    return 'assets/images/sunw.png';
  }

  /// Returns asset path for big card header image
  static String mainAsset(int code, {double windSpeed = 0}) {
    if (windSpeed >= 30) return 'assets/images/windw.png';
    if (code == 0 || code <= 2) return 'assets/images/sun.png';
    if (code <= 48) return 'assets/images/windw.png';
    if (code >= 51) return 'assets/images/rainw.png';
    return 'assets/images/sun.png';
  }

  /// Returns color for forecast card status text
  static int colorValue(int code, {double windSpeed = 0}) {
    if (windSpeed >= 30) return 0xFF49A6C8;
    if (code == 0 || code <= 2) return 0xFFFF9F1C;
    if (code <= 48) return 0xFF49A6C8;
    if (code >= 51) return 0xFF4A90E2;
    return 0xFFFF9F1C;
  }

  /// Icon for mini hourly box — better visual icons
  static IconData hourlyIcon(int code, double windSpeed) {
    if (windSpeed >= 30) return Icons.air_rounded;
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code <= 2) return Icons.filter_drama_rounded;
    if (code == 3) return Icons.cloud_rounded;
    if (code <= 48) return Icons.foggy;
    if (code <= 55) return Icons.grain_rounded;
    if (code <= 67) return Icons.umbrella_rounded;
    if (code <= 77) return Icons.ac_unit_rounded;
    if (code <= 82) return Icons.umbrella_rounded;
    return Icons.thunderstorm_rounded;
  }

  /// Icon color for mini hourly box
  static Color hourlyIconColor(int code, double windSpeed) {
    if (windSpeed >= 30) return Colors.white70;
    if (code == 0) return const Color(0xFFFFD323);   // sunny yellow
    if (code <= 2) return const Color(0xFFFFE57A);   // partly cloudy pale yellow
    if (code == 3) return Colors.white70;             // cloudy white
    if (code <= 48) return Colors.white54;            // foggy dim white
    if (code <= 82) return const Color(0xFF90CAF9);  // rain light blue
    return const Color(0xFFCE93D8);                  // thunder purple
  }
}

// ─── Service ──────────────────────────────────────────────────────────────────

class WeatherService {
  /// Extract clean city name from device location string.
  /// e.g. "Tangerang, House" → "Tangerang"
  static String extractCityName(String location) {
    final parts = location.split(',');
    return parts.first.trim();
  }

  /// Geocode city name → (lat, lon) using Nominatim.
  static Future<Map<String, double>> _geocode(String cityName) async {
    final encoded = Uri.encodeComponent(cityName);
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=$encoded'
      '&format=json'
      '&limit=1'
      '&countrycodes=id',
    );

    final response = await http.get(url, headers: {'User-Agent': 'aerodry-app'});
    if (response.statusCode != 200) throw Exception('Geocoding failed');

    final List<dynamic> data = jsonDecode(response.body);
    if (data.isEmpty) throw Exception('City not found: $cityName');

    return {
      'lat': double.parse(data[0]['lat'].toString()),
      'lon': double.parse(data[0]['lon'].toString()),
    };
  }

  /// Fetch full weather data for a given device location string.
  static Future<WeatherData> fetchForLocation(String deviceLocation) async {
    final cityName = extractCityName(deviceLocation);
    final coords = await _geocode(cityName);
    final lat = coords['lat']!;
    final lon = coords['lon']!;

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat'
      '&longitude=$lon'
      '&hourly=temperature_2m,weathercode,windspeed_10m,relativehumidity_2m,uv_index'
      '&daily=weathercode,temperature_2m_max,precipitation_probability_max'
      '&timezone=Asia%2FJakarta'
      '&forecast_days=8',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) throw Exception('Weather API failed');

    final data = jsonDecode(response.body);

    // ── Hourly ──────────────────────────────────────────────────────────────
    final List<String> times = List<String>.from(data['hourly']['time']);
    final List<dynamic> temps = data['hourly']['temperature_2m'];
    final List<dynamic> codes = data['hourly']['weathercode'];
    final List<dynamic> winds = data['hourly']['windspeed_10m'];
    final List<dynamic> humids = data['hourly']['relativehumidity_2m'];
    final List<dynamic> uvs = data['hourly']['uv_index'];

    // Find current hour index
    final now = DateTime.now();
    final currentHourStr =
        '${now.year}-${_pad(now.month)}-${_pad(now.day)}T${_pad(now.hour)}:00';
    int currentIdx = times.indexWhere((t) => t == currentHourStr);
    if (currentIdx < 0) currentIdx = 0;

    // Build 6 hourly items (now + next 5 hours)
    final hourlyList = <HourlyWeather>[];
    for (int i = 0; i < 6; i++) {
      final idx = currentIdx + i;
      if (idx >= times.length) break;
      final hourNum = int.parse(times[idx].substring(11, 13));
      hourlyList.add(HourlyWeather(
        hour: i == 0 ? 'Now' : _formatHour(hourNum),
        temperature: (temps[idx] as num).round(),
        weatherCode: (codes[idx] as num).toInt(),
        windSpeed: (winds[idx] as num).toDouble(),
        humidity: (humids[idx] as num).toInt(),
        uvIndex: (uvs[idx] as num).toDouble(),
      ));
    }

    final current = hourlyList.isNotEmpty
        ? hourlyList.first
        : HourlyWeather(
            hour: 'Now',
            temperature: 30,
            weatherCode: 0,
            windSpeed: 10,
            humidity: 70,
            uvIndex: 2,
          );

    // ── Daily ────────────────────────────────────────────────────────────────
    final List<String> dailyDates =
        List<String>.from(data['daily']['time']);
    final List<dynamic> dailyCodes = data['daily']['weathercode'];
    final List<dynamic> dailyMaxTemps = data['daily']['temperature_2m_max'];
    final List<dynamic> dailyPrecip =
        data['daily']['precipitation_probability_max'];

    final dailyList = <DailyWeather>[];
    for (int i = 0; i < 7 && i < dailyDates.length; i++) {
      final parts = dailyDates[i].split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      dailyList.add(DailyWeather(
        date: date,
        weatherCode: (dailyCodes[i] as num).toInt(),
        maxTemp: (dailyMaxTemps[i] as num).round(),
        precipitationProbability: dailyPrecip[i] != null
            ? (dailyPrecip[i] as num).toInt()
            : 0,
      ));
    }

    return WeatherData(
      cityName: cityName,
      current: current,
      hourly: hourlyList,
      daily: dailyList,
    );
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  static String _formatHour(int hour) {
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h$suffix';
  }
}
