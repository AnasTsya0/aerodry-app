import 'package:flutter/material.dart';

class ManualPage extends StatelessWidget {
  const ManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF5A7BEF),
                  ),
                ),

                const Center(
                  child: Column(
                    children: [
                      Text(
                        "Manual Control",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Control the clothesline manually as needed",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4E6FD8), Color(0xFF72B1FF)],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Drying Status",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                CircleAvatar(
                                  radius: 4,
                                  backgroundColor: Colors.greenAccent,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "Online",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.15),
                            ),
                            child: const Icon(
                              Icons.local_laundry_service_rounded,
                              color: Colors.white,
                              size: 65,
                            ),
                          ),

                          const SizedBox(width: 18),

                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _infoItem(
                                        Icons.timer_outlined,
                                        "Drying Duration",
                                        "35 Minutes",
                                      ),
                                    ),
                                    Expanded(
                                      child: _infoItem(
                                        Icons.settings,
                                        "Mode",
                                        "Automatic",
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _infoItem(
                                        Icons.access_time,
                                        "Last Updated",
                                        "9:40 AM",
                                      ),
                                    ),
                                    Expanded(
                                      child: _infoItem(
                                        Icons.wb_sunny_outlined,
                                        "Weather Condition",
                                        "Clear Sky",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 45),

                _sectionTitle("Control"),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RaiseClotheslinePage(),
                            ),
                          );
                        },
                        child: _controlButton(
                          icon: Icons.keyboard_double_arrow_up,
                          title: "Raise Clothesline",
                          subtitle: "Lift the clothesline up",
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const LowerClotheslinePage(),
                            ),
                          );
                        },
                        child: _controlButton(
                          icon: Icons.keyboard_double_arrow_down,
                          title: "Lower Clothesline",
                          subtitle: "Lower the clothesline down",
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                _sectionTitle("Emergency"),

                const SizedBox(height: 28),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmergencyStopPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4C4C),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.stop_rounded, color: Colors.white, size: 34),
                        SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Stop the process",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Stop all clothesline movements",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _sectionTitle(String title) {
    return Row(
      children: [
        Expanded(
          child: Divider(thickness: 1, color: Colors.blueGrey.withOpacity(0.2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Divider(thickness: 1, color: Colors.blueGrey.withOpacity(0.2)),
        ),
      ],
    );
  }

  static Widget _infoItem(IconData icon, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  static Widget _controlButton({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEFF3FA),
            ),
            child: Icon(icon, color: Color(0xFF5A7BEF), size: 42),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5A7BEF),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class RaiseClotheslinePage extends StatelessWidget {
  const RaiseClotheslinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DetailControlPage(
      title: "Raise Clothesline",
      icon: Icons.keyboard_double_arrow_up,
      description: "The clothesline is being lifted up.",
    );
  }
}

class LowerClotheslinePage extends StatelessWidget {
  const LowerClotheslinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DetailControlPage(
      title: "Lower Clothesline",
      icon: Icons.keyboard_double_arrow_down,
      description: "The clothesline is being lowered down.",
    );
  }
}

class EmergencyStopPage extends StatelessWidget {
  const EmergencyStopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DetailControlPage(
      title: "Emergency Stop",
      icon: Icons.stop_rounded,
      description: "All clothesline movements have been stopped.",
      isEmergency: true,
    );
  }
}

class DetailControlPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final bool isEmergency;

  const DetailControlPage({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    this.isEmergency = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF5A7BEF),
                  ),
                ),
              ),

              const SizedBox(height: 80),

              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isEmergency
                      ? const Color(0xFFFF4C4C).withOpacity(0.15)
                      : const Color(0xFF5A7BEF).withOpacity(0.15),
                ),
                child: Icon(
                  icon,
                  size: 70,
                  color: isEmergency
                      ? const Color(0xFFFF4C4C)
                      : const Color(0xFF5A7BEF),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 40),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isEmergency
                      ? const Color(0xFFFF4C4C)
                      : const Color(0xFF5A7BEF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    "Process Started",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
