import 'package:flutter/material.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  double sensitivity = 1; // 0=Low, 1=Medium, 2=High
  String? _selectedMotion; // 'alarm' or 'autoRetract'
  int _actionDelay = 5; // seconds
  bool _showDelayDropdown = false;
  bool nightMode = true;
  bool activityNotifications = true;
  bool securitySchedule = true;

  /// Returns label for current sensitivity level
  String _sensitivityLabel() {
    if (sensitivity == 0) return 'Low';
    if (sensitivity == 2) return 'High';
    return 'Medium';
  }

  /// Handle motion option selection — also adjusts sensitivity
  void _selectMotion(String option) {
    setState(() {
      _selectedMotion = option;
      if (option == 'alarm') {
        sensitivity = 1; // Medium
      } else if (option == 'autoRetract') {
        sensitivity = 2; // High
      }
    });
  }

  /// Toggle the delay dropdown
  void _toggleDelayDropdown() {
    setState(() {
      _showDelayDropdown = !_showDelayDropdown;
    });
  }

  /// Select a delay value from the dropdown
  void _selectDelay(int seconds) {
    setState(() {
      _actionDelay = seconds;
      _showDelayDropdown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
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
                  const Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'Security',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0B3B7A),
                              height: 1,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Device Setting Preferences',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF7A8CA8),
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 22),
                ],
              ),

              const SizedBox(height: 24),

              // SECURITY STATUS CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4867B8),
                      Color(0xFF80CBF1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Security Status',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Transform.translate(
                        offset: const Offset(10, 0),
                        child: Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0x66FFFFFF),
                            border: Border.all(
                                color: Colors.white70,
                            ),
                            ),
                            child: Center(
                            child: Image.asset(
                                'assets/images/seclogo.png',
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                            ),
                            ),
                        ),
                        ),

                        const SizedBox(width: 20),

                        const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text.rich(
                            TextSpan(
                                text: 'System Status : ',
                                style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                ),
                                children: [
                                TextSpan(
                                    text: 'Safe',
                                    style: TextStyle(
                                    color: Color(0xFF23FF71),
                                    ),
                                ),
                                ],
                            ),
                            ),

                            SizedBox(height: 0),

                            Text(
                            'No threats detected',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                            ),
                            ),
                        ],
                        ),
                    ],
                    ),
                    const SizedBox(height: 10),

                    Container(height: 1, color: Colors.white24),

                    const SizedBox(height: 14),

                    Row(
                    children: [
                        Flexible(
                        flex: 6,
                        child: _MiniInfo(
                            icon: Icons.timer_outlined,
                            title: 'Last Detected',
                            value: '5 minutes ago',
                        ),
                        ),

                        Container(
                        width: 1,
                        height: 35,
                        color: Colors.white24,
                        ),

                        Flexible(
                        flex: 7,
                        child: _MiniInfo(
                            icon: Icons.wb_sunny_outlined,
                            title: 'Weather Condition',
                            value: 'Clear Sky',
                        ),
                        ),
                    ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Security Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B3B7A),
                ),
              ),

              const SizedBox(height: 14),

              // DETECTION SENSITIVITY — dynamic label
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detection Sensitivity',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1C3657),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _sensitivityLabel(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1F5592),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF4C75D9),
                  inactiveTrackColor: const Color(0xFFD4DEEA),
                  thumbColor: Colors.white,
                  overlayColor: const Color(0x334C75D9),
                  trackHeight: 5,
                ),
                child: Slider(
                  value: sensitivity,
                  min: 0,
                  max: 2,
                  divisions: 2,
                  onChanged: (value) {
                    setState(() {
                      sensitivity = value;
                    });
                  },
                ),
              ),

              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Low',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Medium',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    'High',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Medium sensitivity is recommended for indoor environment',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              const Text(
                'When Motion Detected',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B3B7A),
                ),
              ),

              const SizedBox(height: 14),

              // MOTION OPTIONS — clickable with auto sensitivity
              _MotionOption(
                selected: _selectedMotion == 'alarm',
                icon: Icons.notifications_none,
                title: 'Alarm',
                subtitle: 'Trigger alarm and send notification',
                onTap: () => _selectMotion('alarm'),
              ),

              _MotionOption(
                selected: _selectedMotion == 'autoRetract',
                icon: Icons.flag_outlined,
                title: 'Auto Retract',
                subtitle: 'Automatically retract the clothesline',
                onTap: () => _selectMotion('autoRetract'),
              ),

              const SizedBox(height: 8),

              // ACTION DELAY — tappable with dropdown
              GestureDetector(
                onTap: _toggleDelayDropdown,
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 22,
                      color: Color(0xFF1C3657),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Text(
                        'Action Delay',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1C3657),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    Text(
                      '$_actionDelay Seconds',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1F5592),
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    Icon(
                      _showDelayDropdown
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFF1F5592),
                    ),
                  ],
                ),
              ),

              // DELAY DROPDOWN
              if (_showDelayDropdown)
                Container(
                  margin: const EdgeInsets.only(left: 34, top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [1, 3, 5, 10, 15, 30].map((seconds) {
                      final isSelected = _actionDelay == seconds;
                      return InkWell(
                        onTap: () => _selectDelay(seconds),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEAF4FF)
                                : Colors.transparent,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$seconds Seconds',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected
                                      ? const Color(0xFF1F5592)
                                      : const Color(0xFF1C3657),
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Color(0xFF1F5592),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.only(left: 34, top: 4),
                child: Text(
                  'Set a delay before action is taken after motion is detected',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              const Text(
                'Device Security Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B3B7A),
                ),
              ),

              const SizedBox(height: 14),

              _SecuritySwitch(
                icon: Icons.nightlight_round,
                title: 'Night Mode',
                subtitle:
                    'Activate security at night or low light conditions',
                value: nightMode,
                onChanged: (value) {
                  setState(() {
                    nightMode = value;
                  });
                },
              ),

              _SecuritySwitch(
                icon: Icons.chat_bubble_outline,
                title: 'Activity Notifications',
                subtitle: 'Receive notifications for detected motion',
                value: activityNotifications,
                onChanged: (value) {
                  setState(() {
                    activityNotifications = value;
                  });
                },
              ),


              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MiniInfo({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),

        const SizedBox(width: 6),

        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MotionOption extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MotionOption({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              size: 18,
              color: selected
                  ? const Color(0xFF4C75D9)
                  : const Color(0xFF1C3657),
            ),

            const SizedBox(width: 18),

            Icon(
              icon,
              size: 24,
              color: const Color(0xFF1C3657),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C3657),
                    ),
                  ),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecuritySwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SecuritySwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: const Color(0xFF1C3657),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C3657),
                  ),
                ),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF1F5592),
          ),
        ],
      ),
    );
  }
}