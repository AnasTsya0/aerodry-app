import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aerodry_app/constants/app_state.dart';
import 'package:aerodry_app/services/firebase_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  double sensitivity = 1; // 0=Low, 1=Medium, 2=High
  String? _selectedMotion; // 'alarm' or 'autoRetract'

  @override
  void initState() {
    super.initState();
    SecurityState.securityMode.addListener(_onSecurityChange);
    SecurityState.alarmTriggered.addListener(_onSecurityChange);
    DryingState.weatherCondition.addListener(_onSecurityChange);
    _loadSettings();
  }

  @override
  void dispose() {
    SecurityState.securityMode.removeListener(_onSecurityChange);
    SecurityState.alarmTriggered.removeListener(_onSecurityChange);
    DryingState.weatherCondition.removeListener(_onSecurityChange);
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final autoRetract = prefs.getBool('autoRetract') ?? false;
    setState(() {
      _selectedMotion = autoRetract ? 'autoRetract' : 'alarm';
      sensitivity = autoRetract ? 2 : 1;
    });
    // Sinkronkan ke Firebase: activityNotifications = true untuk Alarm, false untuk Retract
    FirebaseService.instance.setActivityNotifications(!autoRetract);
  }

  void _onSecurityChange() {
    if (mounted) setState(() {});
  }

  String _sensitivityLabel() {
    if (sensitivity == 0) return 'Low';
    if (sensitivity == 2) return 'High';
    return 'Medium';
  }

void _selectMotion(String option) async {
  print('🔘 _selectMotion dipanggil dengan opsi: $option');
  final prefs = await SharedPreferences.getInstance();
  final isAlarmOnly = option == 'alarm';
  print('📦 isAlarmOnly = $isAlarmOnly');
  await prefs.setBool('autoRetract', !isAlarmOnly);
  setState(() {
    _selectedMotion = option;
    sensitivity = isAlarmOnly ? 1 : 2;
  });
  print('📡 Memanggil setActivityNotifications($isAlarmOnly)');
  FirebaseService.instance.setActivityNotifications(isAlarmOnly);
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

              // SECURITY STATUS CARD (tetap seperti sebelumnya, tanpa perubahan)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4867B8), Color(0xFF80CBF1)],
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
                              border: Border.all(color: Colors.white70),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'System Status : ',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  TextSpan(
                                    text: SecurityState.alarmTriggered.value ? 'Alert!' : 'Safe',
                                    style: TextStyle(
                                      color: SecurityState.alarmTriggered.value
                                          ? const Color(0xFFFF4444)
                                          : const Color(0xFF23FF71),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 0),
                            Text(
                              SecurityState.alarmTriggered.value
                                  ? 'Motion detected near clothesline'
                                  : 'No threats detected',
                              style: const TextStyle(fontSize: 13, color: Colors.white),
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
                            value: SecurityState.alarmTriggered.value ? 'Just now' : 'No detection',
                          ),
                        ),
                        Container(width: 1, height: 35, color: Colors.white24),
                        Flexible(
                          flex: 7,
                          child: _MiniInfo(
                            icon: Icons.wb_sunny_outlined,
                            title: 'Weather Condition',
                            value: DryingState.weatherCondition.value,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // DETECTION SENSITIVITY
              const Text(
                'Security Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B3B7A),
                ),
              ),
              const SizedBox(height: 14),
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
                    setState(() => sensitivity = value);
                  },
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Low', style: TextStyle(fontSize: 12)),
                  Text('Medium', style: TextStyle(fontSize: 12)),
                  Text('High', style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.grey),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Medium sensitivity is recommended for indoor environment',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
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

              // MOTION OPTIONS
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

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Widget Mini Info ─────────────────────────────────────────────
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
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.white70)),
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Motion Option ────────────────────────────────────────────────
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
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: selected ? const Color(0xFF4C75D9) : const Color(0xFF1C3657),
            ),
            const SizedBox(width: 18),
            Icon(icon, size: 24, color: const Color(0xFF1C3657)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C3657))),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}