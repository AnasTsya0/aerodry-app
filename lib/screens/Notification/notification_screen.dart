import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aerodry_app/constants/notification_state.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    NotificationState.entries.addListener(_onEntriesChange);
  }

  @override
  void dispose() {
    NotificationState.entries.removeListener(_onEntriesChange);
    super.dispose();
  }

  void _onEntriesChange() {
    if (mounted) setState(() {});
  }

  /// Get current Jakarta time (UTC+7)
  DateTime _getJakartaTime() {
    return DateTime.now().toUtc().add(const Duration(hours: 7));
  }

  void _markAllAsRead() {
    NotificationState.markAllAsRead();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF0B3B7A);
    final jakartaTime = _getJakartaTime();
    final dateStr = DateFormat('EEEE MMM dd').format(jakartaTime);
    final entries = NotificationState.entries.value;
    final hasEntries = entries.isNotEmpty;
    final allRead = NotificationState.allRead;

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
                  onTap: allRead ? null : _markAllAsRead,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 14,
                        color: allRead
                            ? Colors.grey
                            : const Color(0xFF4C75D8),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Mark all as read',
                        style: TextStyle(
                          fontSize: 14,
                          color: allRead
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
                      if (hasEntries && !allRead) ...[
                        ...entries.map((entry) => Column(
                          children: [
                            _TimeLabel(time: entry.formattedTime),
                            _NotificationCard(
                              title: entry.title,
                              subtitle: entry.subtitle,
                              temperature: entry.temperature,
                              city: entry.city,
                              img: entry.img,
                              iconBg: entry.iconBg,
                              sideColor: entry.sideColor,
                              titleColor: entry.titleColor,
                              weatherIcon: entry.isRain
                                  ? Icons.cloudy_snowing
                                  : Icons.wb_sunny_rounded,
                            ),
                            const SizedBox(height: 16),
                          ],
                        )),
                        const SizedBox(height: 18),
                      ],

                      if (!hasEntries || allRead) ...[
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