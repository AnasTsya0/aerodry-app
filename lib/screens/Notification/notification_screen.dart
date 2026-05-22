import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // HEADER
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF1C4587),
                    ),
                  ),

                  const Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF123A7C),
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Monday May 01',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 28),

              // MARK ALL
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 22,
                      color: Color(0xFF4C75D8),
                    ),

                    SizedBox(width: 6),

                    Text(
                      'Mark all as read',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1C4587),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      _TimeLabel(time: 'Just now'),

                      _NotificationCard(
                        title: 'Motion Detected',
                        subtitle: 'Activity Detected In The Laundry Area',
                        temperature: '28°',
                        city: 'Jakarta',
                        icon: Icons.directions_run,
                        img: 'assets/images/motioncard.png',
                        iconBg: Color(0xFFFFD8D8),
                        iconColor: Colors.red,
                        sideColor: Colors.red,
                        titleColor: Colors.red,
                        weatherIcon: Icons.wb_sunny_rounded,
                      ),

                      SizedBox(height: 24),

                      _TimeLabel(time: '10 min ago'),

                      _NotificationCard(
                        title: 'No Motion Detected',
                        subtitle: 'Clothesline Area Is Safe',
                        temperature: '29°',
                        city: 'Jakarta',
                        icon: Icons.shield_outlined,
                        img: 'assets/images/nomotioncard.png',
                        iconBg: Color(0xFFD8FFE8),
                        iconColor: Color(0xFF22C55E),
                        sideColor: Color(0xFF22C55E),
                        titleColor: Color(0xFF4A4A4A),
                        weatherIcon: Icons.wb_sunny_rounded,
                      ),

                      SizedBox(height: 24),

                      _TimeLabel(time: '1 hour ago'),

                      _NotificationCard(
                        title: 'Retracted Alert',
                        subtitle: 'Rain Detected',
                        temperature: '29°',
                        city: 'Jakarta',
                        icon: Icons.dry_cleaning_outlined,
                        img: 'assets/images/tutupjemurancard.png',
                        iconBg: Color(0xFFE5E5E5),
                        iconColor: Colors.grey,
                        sideColor: Colors.grey,
                        titleColor: Color(0xFF4A4A4A),
                        weatherIcon: Icons.wb_sunny_rounded,
                      ),

                      SizedBox(height: 24),

                      _TimeLabel(time: '5 hour ago'),

                      _NotificationCard(
                        title: 'Extended Alert',
                        subtitle: 'Heat Warning Retracted',
                        temperature: '29°',
                        city: 'Jakarta',
                        icon: Icons.dry_cleaning_outlined,
                        img: 'assets/images/bukajemurancard.png',
                        iconBg: Color(0xFFDCE6FF),
                        iconColor: Color(0xFF5B7FFF),
                        sideColor: Color(0xFF5B7FFF),
                        titleColor: Color(0xFF4A4A4A),
                        weatherIcon: Icons.cloudy_snowing,
                      ),

                      SizedBox(height: 40),

                      _BottomInfoCard(),
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

// TIME LABEL
class _TimeLabel extends StatelessWidget {
  final String time;

  const _TimeLabel({
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.access_time_rounded,
          size: 24,
          color: Color(0xFF123A7C),
        ),

        const SizedBox(width: 8),

        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF123A7C),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// NOTIFICATION CARD
class _NotificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String temperature;
  final String city;

  final IconData icon;
  final IconData weatherIcon;

  final String? img;

  final Color iconBg;
  final Color iconColor;
  final Color sideColor;
  final Color titleColor;

  const _NotificationCard({
    required this.title,
    required this.subtitle,
    required this.temperature,
    required this.city,
    required this.icon,
    required this.weatherIcon,
    this.img,
    required this.iconBg,
    required this.iconColor,
    required this.sideColor,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // SIDE COLOR
          Container(
            width: 8,
            decoration: BoxDecoration(
              color: sideColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  // ICON / IMAGE
                  Container(
                    width: 95,
                    height: 95,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),

                    child: img != null
                        ? Padding(
                            padding: const EdgeInsets.only(
                              left: 6,
                              top: 2,
                            ),
                            child: Image.asset(
                              img!,
                              width: 98,
                              height: 98,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            icon,
                            size: 42,
                            color: iconColor,
                          ),
                  ),

                  const SizedBox(width: 18),

                  // TEXT CONTENT
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Icon(
                              weatherIcon,
                              size: 22,
                              color: Colors.amber,
                            ),

                            const SizedBox(width: 6),

                            Text(
                              temperature,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(width: 24),

                            const Icon(
                              Icons.location_on_outlined,
                              size: 20,
                              color: Colors.grey,
                            ),

                            const SizedBox(width: 4),

                            Text(
                              city,
                              style: const TextStyle(
                                fontSize: 15,
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

// BOTTOM CARD
class _BottomInfoCard extends StatelessWidget {
  const _BottomInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEBFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4C75D8),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.priority_high_rounded,
              color: Color(0xFF4C75D8),
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're all caught up!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  "All notifications for today have\nbeen read.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.notifications_active_rounded,
            size: 40,
            color: Color(0xFF4C75D8),
          ),
        ],
      ),
    );
  }
}