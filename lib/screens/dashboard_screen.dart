import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aerodry_app/screens/profile/profile_screen.dart';
import 'package:aerodry_app/screens/weather/weather_screen.dart';
import 'package:aerodry_app/services/weather_service.dart';
import 'package:aerodry_app/constants/app_state.dart';
import 'package:aerodry_app/constants/notification_state.dart';
import 'package:aerodry_app/screens/manual/manual_screen.dart';
import 'package:aerodry_app/screens/Notification/notification_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const blueDark = Color(0xFF4E6EC4);
  static const blueLight = Color(0xFF74C0F3);
  static const bg = Color(0xFFEAF4FF);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with RouteAware {
  WeatherData? _weather;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // Called when navigating back to this screen
  @override
  void didPopNext() {
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() => _loading = true);
    try {
      final location = deviceList.isNotEmpty
          ? deviceList[activeDeviceIndex].location
          : 'Tangerang';
      final data = await WeatherService.fetchForLocation(location);
      if (mounted) setState(() { _weather = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardScreen.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 100),
                  child: Column(
                    children: [
                      const _Header(),
                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WeatherScreen(),
                            ),
                          );
                          // Refresh when back from WeatherScreen
                          _fetchWeather();
                        },
                        child: _WeatherCard(
                          weather: _weather,
                          loading: _loading,
                        ),
                      ),

                      const SizedBox(height: 12),
                      const _DryingCard(),
                      const SizedBox(height: 12),

                      Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ManualScreen(),
                                ),
                              );
                            },
                            child: const _MiniCard(
                              title: 'Manual Control',
                              imagePath: 'assets/images/manualkeluar.png',
                              label: 'Rack Status',
                              value: 'Extended',
                              footerText: 'Last opened\n45 minutes ago',
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        const Expanded(
                          child: _MiniCard(
                            title: 'Security',
                            imagePath: 'assets/images/seclogo.png',
                            label: 'System Status',
                            value: 'Safe',
                            footerText: 'Last checked\n1 minute ago',
                          ),
                        ),
                      ],
                    ),
                    ],
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 10,
                  child: _BottomNav(onProfileReturn: _fetchWeather),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header();

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  late Timer _timer;
  late DateTime _jakartaTime;

  /// Get current Jakarta time (UTC+7)
  DateTime _getJakartaTime() {
    return DateTime.now().toUtc().add(const Duration(hours: 7));
  }

  /// Greeting based on hour of day
  String _getGreeting(int hour) {
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    if (hour >= 17 && hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  @override
  void initState() {
    super.initState();
    _jakartaTime = _getJakartaTime();
    // Update every second for live clock
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _jakartaTime = _getJakartaTime());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting(_jakartaTime.hour);
    final dayName = DateFormat('EEEE').format(_jakartaTime);
    final timeStr = DateFormat('h:mm a').format(_jakartaTime);

    return Row(
      children: [
        Image.asset(
          'assets/images/profile.png',
          width: 30,
          height: 30,
          fit: BoxFit.contain,
          color: Colors.black,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              Text(
                '$dayName, $timeStr',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
          child: ValueListenableBuilder<bool>(
            valueListenable: NotificationState.hasUnread,
            builder: (context, hasUnread, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none_rounded, size: 30),
                  if (hasUnread)
                    Positioned(
                      right: 3,
                      top: 3,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final WeatherData? weather;
  final bool loading;

  const _WeatherCard({this.weather, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final w = weather;
    final cityName = w?.cityName ??
        (deviceList.isNotEmpty
            ? WeatherService.extractCityName(deviceList[activeDeviceIndex].location)
            : 'Loading...');

    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DashboardScreen.blueDark, DashboardScreen.blueLight],
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
      child: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  cityName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  w != null ? '${w.current.temperature}°' : '--°',
                  style: const TextStyle(
                    fontSize: 35,
                    height: 0.95,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Image.asset(
                  w != null
                      ? WeatherCodeHelper.mainAsset(w.current.weatherCode,
                          windSpeed: w.current.windSpeed)
                      : 'assets/images/sun.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _WeatherInfo(
                      icon: Icons.water_drop,
                      title: 'Humidity',
                      value: w != null ? '${w.current.humidity}%' : '--',
                    ),
                    _WeatherInfo(
                      icon: Icons.sunny,
                      title: 'UV Index',
                      value: w != null
                          ? w.current.uvIndex.toStringAsFixed(1)
                          : '--',
                    ),
                    _WeatherInfo(
                      icon: Icons.air,
                      title: 'Wind Speed',
                      value: w != null
                          ? '${w.current.windSpeed.round()}km/h'
                          : '--',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (w != null)
                        ...w.hourly.asMap().entries.map((e) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (e.key > 0) const SizedBox(width: 9),
                            _ForecastItem(
                              day: e.value.hour,
                              icon: WeatherCodeHelper.hourlyIcon(
                                  e.value.weatherCode, e.value.windSpeed),
                              iconColor: WeatherCodeHelper.hourlyIconColor(
                                  e.value.weatherCode, e.value.windSpeed),
                              temp: '${e.value.temperature}°',
                            ),
                          ],
                        ))
                      else
                        ...[1, 2, 3, 4, 5, 6].map((_) => const Padding(
                              padding: EdgeInsets.only(right: 9),
                              child: _ForecastItem(
                                day: '--',
                                icon: Icons.wb_sunny_rounded,
                                iconColor: Color(0xFFFFD323),
                                temp: '--',
                              ),
                            )),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

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

class _ForecastItem extends StatelessWidget {
  final String day;
  final IconData icon;
  final Color iconColor;
  final String temp;

  const _ForecastItem({
    required this.day,
    required this.icon,
    required this.iconColor,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    final isNow = day == 'Now';
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
            day,
            style: TextStyle(
              fontSize: isNow ? 10.5 : 11,
              fontWeight: isNow ? FontWeight.w800 : FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Icon(icon, size: 19, color: iconColor),
          const SizedBox(height: 4),
          Text(
            temp,
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

class _DryingCard extends StatelessWidget {
  const _DryingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DashboardScreen.blueDark, DashboardScreen.blueLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 9),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const SizedBox(width: 58),

                const Expanded(
                  child: Center(
                    child: Text(
                      'Drying Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                Transform.translate(
                  offset: const Offset(-4, 9),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 3, 55, 30),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        CircleAvatar(
                          radius: 2,
                          backgroundColor: Color(0xFF42EF7D),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Color.fromARGB(255, 4, 170, 57),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 60),

                  Transform.translate(
                    offset: const Offset(0, 3),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Image.asset(
                            'assets/images/jemurandry.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DryingText(
                            icon: Icons.timer_outlined,
                            title: 'Drying Duration',
                            value: '35 Minutes',
                          ),

                          SizedBox(height: 10),

                          _DryingText(
                            icon: Icons.settings_outlined,
                            title: 'Mode',
                            value: 'Automatic',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -5),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.14),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Transform.translate(
                        offset: const Offset(-20, 0),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: _BottomInfo(
                            icon: Icons.timer_outlined,
                            title: 'Last Update',
                            value: '9 : 15',
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(-12, 0),
                      child: const SizedBox(
                        height: 22,
                        child: VerticalDivider(
                          color: Colors.white30,
                          width: 1,
                          thickness: 1,
                        ),
                      ),
                    ),

                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: _BottomInfo(
                          icon: Icons.wb_sunny_outlined,
                          title: 'Weather Condition',
                          value: 'Clear Sky',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DryingText extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DryingText({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 25),
        const SizedBox(width: 7),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),

            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                height: 1.05,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BottomInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _BottomInfo({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 4),

          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final String label;
  final String value;
  final String footerText;

  const _MiniCard({
    required this.title,
    required this.imagePath,
    required this.label,
    required this.value,
    required this.footerText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DashboardScreen.blueDark, DashboardScreen.blueLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 9, 2, 10),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: const Offset(5, 0), // kiri kanan
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(imagePath, fit: BoxFit.contain),
                        ),
                      ),
                    ),

                    const SizedBox(width: 11),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                                height: 1,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              value,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4DFF88),
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 19,
                      color: Colors.white60,
                    ),

                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        footerText,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            right: 10,
            bottom: 15,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final VoidCallback? onProfileReturn;

  const _BottomNav({this.onProfileReturn});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // NAVBAR PUTIH
          Positioned(
            bottom: 0,
            child: Image.asset(
              'assets/images/navbar.png',
              width: 330,
              fit: BoxFit.contain,
            ),
          ),

          // ICON LIST
          Positioned(
            left: 60,
            bottom: 26,
            child: Image.asset(
              'assets/images/navbarlog.png',
              width: 35,
              height: 35,
            ),
          ),

          // ICON PROFILE
          Positioned(
            right: 60,
            bottom: 25,
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
                // Refresh weather when returning from profile (device may have changed)
                onProfileReturn?.call();
              },
              child: Image.asset(
                'assets/images/profile.png',
                width: 35,
                height: 35,
              ),
            ),
          ),

          // BULETAN BIRU
          Positioned(
            top: -9,
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4E6EC4), Color(0xFF74C0F3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              // ICON HOME
              child: Center(
                child: Image.asset(
                  'assets/images/navbarhome.png',
                  width: 35,
                  height: 35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
