import 'package:flutter/material.dart';
import 'package:aerodry_app/screens/onboarding/onboarding_screen.dart';
import 'package:aerodry_app/screens/profile/connected_device_screen.dart';
import 'package:aerodry_app/screens/dashboard_screen.dart';
import 'package:aerodry_app/constants/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final hasDevice = deviceList.isNotEmpty;
    final activeDevice = hasDevice ? deviceList[activeDeviceIndex] : null;
    final deviceId = hasDevice ? activeDevice!.name : 'No device';
    final deviceLocation = hasDevice ? activeDevice!.location : 'Unknown location';

    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 33),
          child: Column(
            children: [
              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF5E87FF),
                    size: 30,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFC9DCF7),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/profilescr.png',
                  width: 35,
                  height: 35,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Rania',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF174984),
                ),
              ),

              const SizedBox(height: 2),

              const Text(
                'raniamasyaputri@gmail.com',
                style: TextStyle(fontSize: 14, color: Color(0xFF6E8DB0)),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFC9F1D4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: Color(0xFF24BF58)),
                    SizedBox(width: 4),
                    Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF24BF58),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 13),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 17,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 34,
                          width: 34,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F6FF),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Image.asset(
                              'assets/images/profile.png',
                              width: 19,
                              height: 19,
                              fit: BoxFit.contain,
                              color: const Color.fromARGB(255, 0, 36, 129),
                            ),
                          ),
                        ),

                        const SizedBox(width: 18),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'raniamasyaputri@gmail.com',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.35,
                                  color: Color(0xFF9A9A9A),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          width: 23,
                          height: 23,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 0, 54, 190),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ],
                    ),

                    const Divider(
                      height: 19,
                      thickness: 1,
                      color: Color(0xFFE8E8E8),
                    ),

                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ConnectedDevicePage(),
                          ),
                        );
                        // Rebuild to reflect active device changes
                        if (mounted) setState(() {});
                      },
                      child: _ProfileItem(
                        icon: Icons.credit_card_rounded,
                        title: 'Connected Device',
                        subtitle: 'Device ID : $deviceId',
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: Color.fromARGB(255, 0, 36, 129),
                          size: 28,
                        ),
                      ),
                    ),

                    const Divider(
                      height: 19,
                      thickness: 1,
                      color: Color(0xFFE8E8E8),
                    ),

                    GestureDetector(
                      child: _ProfileItem(
                        icon: Icons.location_on_outlined,
                        title: 'Current Location',
                        subtitle: deviceLocation,
                        trailing: const SizedBox(),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OnboardingScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFFF1D1D),
                      size: 20,
                    ),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Color(0xFFFF1D1D),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA7A7),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
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

class _ProfileItem extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _ProfileItem({
    this.icon,
    this.imagePath,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F6FF),
            shape: BoxShape.circle,
          ),
          child: imagePath != null
              ? ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(
                      imagePath!,
                      fit: BoxFit.contain,
                      color: const Color(0xFF3C73FF),
                    ),
                  ),
                )
              : Icon(icon, color: const Color(0xFF3C73FF), size: 21),
        ),

        const SizedBox(width: 18),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: Color(0xFF9A9A9A),
                ),
              ),
            ],
          ),
        ),

        trailing,
      ],
    );
  }
}
