import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const bgColor = Color(0xFFEAF4FF);
  static const blue = Color(0xFF2F77FF);
  static const darkBlue = Color(0xFF0B438F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 390,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: Column(
                children: [
                  const SizedBox(height: 28),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF5C8CFF),
                        size: 28,
                      ),
                    ),
                  ),

                  const SizedBox(height: 58),

                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD5E4FA),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          size: 64,
                          color: darkBlue,
                        ),
                      ),

                      Positioned(
                        right: -3,
                        top: 12,
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: const BoxDecoration(
                            color: blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Rania',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: darkBlue,
                    ),
                  ),

                  const SizedBox(height: 2),

                  const Text(
                    'raniamasyaputri@gmail.com',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8FA1B7),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4FFD9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '● Online',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF49CC48),
                      ),
                    ),
                  ),

                  const SizedBox(height: 72),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Column(
                      children: const [
                        _ProfileItem(
                          icon: Icons.person_outline_rounded,
                          title: 'Email',
                          subtitle: 'raniamasyaputri@gmail.com',
                          trailingIcon: Icons.edit_rounded,
                          showDivider: true,
                        ),

                        _ProfileItem(
                          icon: Icons.devices_rounded,
                          title: 'Connected Device',
                          subtitle: 'Device ID : CLP-7XC5BA',
                          trailingIcon: Icons.chevron_right_rounded,
                          showDivider: true,
                        ),

                        _ProfileItem(
                          icon: Icons.location_on_outlined,
                          title: 'Current Location',
                          subtitle: 'Jakarta, Indonesia\nLast updated : 10 AM',
                          trailingIcon: Icons.chevron_right_rounded,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.red,
                        size: 19,
                      ),

                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.red,
                        ),
                      ),

                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFFFA5AA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 55),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final IconData trailingIcon;
  final bool showDivider;

  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailingIcon,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 64),

          child: Row(
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF4FF),
                  shape: BoxShape.circle,
                ),

                child: Icon(icon, color: ProfileScreen.blue, size: 21),
              ),

              const SizedBox(width: 17),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9AA5B1),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: trailingIcon == Icons.edit_rounded ? 24 : 26,
                height: trailingIcon == Icons.edit_rounded ? 24 : 26,

                decoration: BoxDecoration(
                  color: trailingIcon == Icons.edit_rounded
                      ? ProfileScreen.blue
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),

                child: Icon(
                  trailingIcon,
                  color: trailingIcon == Icons.edit_rounded
                      ? Colors.white
                      : const Color(0xFF8D969F),
                  size: trailingIcon == Icons.edit_rounded ? 13 : 25,
                ),
              ),
            ],
          ),
        ),

        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE5E5E5),
            indent: 54,
          ),
      ],
    );
  }
}
