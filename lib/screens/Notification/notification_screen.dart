import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aerodry_app/constants/notification_state.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late bool _allRead;

  @override
  void initState() {
    super.initState();
    _allRead = NotificationState.allRead;
  }

  /// Get current Jakarta time (UTC+7)
  DateTime _getJakartaTime() {
    return DateTime.now().toUtc().add(const Duration(hours: 7));
  }

  void _markAllAsRead() {
    setState(() {
      _allRead = true;
    });
    // Update global state so dashboard red dot disappears
    NotificationState.markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF0B3B7A);
    final jakartaTime = _getJakartaTime();
    final dateStr = DateFormat('EEEE MMM dd').format(jakartaTime);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF4C75D8),
                      size: 22,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          const Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: darkBlue,
                            ),
                          ),
                          const SizedBox(height: 0),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 22),
                ],
              ),

              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _allRead ? null : _markAllAsRead,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 14,
                        color: _allRead
                            ? Colors.grey
                            : const Color(0xFF4C75D8),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Mark all as read',
                        style: TextStyle(
                          fontSize: 14,
                          color: _allRead
                              ? Colors.grey
                              : const Color(0xFF1C4587),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Show notifications only when not all read
                      if (!_allRead) ...[
                        const _TimeLabel(time: 'Just now'),
                        const _NotificationCard(
                          title: 'Motion Detected',
                          subtitle: 'Activity Detected In The Laundry Area',
                          temperature: '28°',
                          city: 'Jakarta',
                          img: 'assets/images/motioncard.png',
                          iconBg: Color(0xFFFFCACA),
                          sideColor: Colors.red,
                          titleColor: Colors.red,
                          weatherIcon: Icons.wb_sunny_rounded,
                        ),

                        const SizedBox(height: 16),

                        const _TimeLabel(time: '10 min ago'),
                        const _NotificationCard(
                          title: 'No Motion Detected',
                          subtitle: 'Clothesline Area Is Safe',
                          temperature: '29°',
                          city: 'Jakarta',
                          img: 'assets/images/nomotioncard.png',
                          iconBg: Color(0xFFD3FFE4),
                          sideColor: Color(0xFF49EA88),
                          titleColor: Color(0xFF4A4A4A),
                          weatherIcon: Icons.wb_sunny_rounded,
                        ),

                        const SizedBox(height: 16),

                        const _TimeLabel(time: '1 hour ago'),
                        const _NotificationCard(
                          title: 'Retracted Alert',
                          subtitle: 'Rain Detected',
                          temperature: '29°',
                          city: 'Jakarta',
                          img: 'assets/images/tutupjemurancard.png',
                          iconBg: Color(0xFFE5E5E5),
                          sideColor: Colors.grey,
                          titleColor: Color(0xFF4A4A4A),
                          weatherIcon: Icons.wb_sunny_rounded,
                        ),

                        const SizedBox(height: 16),

                        const _TimeLabel(time: '5 hour ago'),
                        const _NotificationCard(
                          title: 'Extended Alert',
                          subtitle: 'Heat Warning Retracted',
                          temperature: '29°',
                          city: 'Jakarta',
                          img: 'assets/images/bukajemurancard.png',
                          iconBg: Color(0xFFDCE6FF),
                          sideColor: Color(0xFF5B7FFF),
                          titleColor: Color(0xFF4A4A4A),
                          weatherIcon: Icons.cloudy_snowing,
                        ),

                        const SizedBox(height: 34),
                      ],

                      // "You're all caught up" only shows after mark all as read
                      if (_allRead) ...[
                        const SizedBox(height: 40),
                        const _BottomInfoCard(),
                      ],

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  final String time;

  const _TimeLabel({required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.access_time_rounded,
          size: 14,
          color: Color(0xFF123A7C),
        ),
        const SizedBox(width: 5),
        Text(
          time,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF123A7C),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String temperature;
  final String city;
  final IconData weatherIcon;
  final String img;
  final Color iconBg;
  final Color sideColor;
  final Color titleColor;

  const _NotificationCard({
    required this.title,
    required this.subtitle,
    required this.temperature,
    required this.city,
    required this.weatherIcon,
    required this.img,
    required this.iconBg,
    required this.sideColor,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            decoration: BoxDecoration(
              color: sideColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                bottomLeft: Radius.circular(7),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 8),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Image.asset(
                        img,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Icon(
                              weatherIcon,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              temperature,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              city,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomInfoCard extends StatelessWidget {
  const _BottomInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEBFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4C75D8),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.priority_high_rounded,
              size: 14,
              color: Color(0xFF4C75D8),
            ),
          ),

          const SizedBox(width: 8),

          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're all caught up!",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "All notifications for today have been read.",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.1,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          Image.asset(
            'assets/images/notifpge.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}