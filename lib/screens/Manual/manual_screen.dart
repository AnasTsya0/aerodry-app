import 'package:flutter/material.dart';

class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Column(
            children: [
              
              /// HEADER
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: Color(0xFF4B7BFF),
                    ),
                  ),

                  const Expanded(
                    child: Column(
                      children: [
                        Text(
                          "Manual Control",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0B3B82),
                          ),
                        ),

                        SizedBox(height: 3),

                        Text(
                          "Control the clothesline manually as needed",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF3D5D8A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 18),
                ],
              ),

              const SizedBox(height: 28),

              /// DRYING STATUS
              Container(
                width: double.infinity,
                height: 170,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF5C7FEF),
                      Color(0xFF7CC7F7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: Stack(
                  children: [

                    /// TITLE
                    const Positioned(
                      top: 0,
                      left: 0,
                      child: Text(
                        "Drying Status",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    /// ONLINE BADGE
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Online",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    /// CLOTHES ICON
                    Positioned(
                      left: 0,
                      bottom: 0,
                      top: 35,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_laundry_service_rounded,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),

                    /// RIGHT INFO
                    Positioned(
                      top: 42,
                      left: 130,
                      right: 0,
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

                              Container(
                                width: 1,
                                height: 45,
                                color: Colors.white.withOpacity(0.3),
                              ),

                              Expanded(
                                child: _infoItem(
                                  Icons.auto_mode,
                                  "Mode",
                                  "Automatic",
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Divider(
                            color: Colors.white.withOpacity(0.3),
                            thickness: 1,
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: _infoItem(
                                  Icons.access_time_rounded,
                                  "Last Updated",
                                  "9:40 AM",
                                ),
                              ),

                              Container(
                                width: 1,
                                height: 45,
                                color: Colors.white.withOpacity(0.3),
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
              ),

              const SizedBox(height: 70),

              /// CONTROL TITLE
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.blueGrey.withOpacity(0.3),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "Control",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B3B82),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Divider(
                      color: Colors.blueGrey.withOpacity(0.3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              /// BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /// RAISE
                  _controlButton(
                    icon: Icons.keyboard_double_arrow_up_rounded,
                    title: "Raise Clothesline",
                    subtitle: "Lift the\nclothesline up",
                  ),

                  /// LOWER
                  _controlButton(
                    icon: Icons.keyboard_double_arrow_down_rounded,
                    title: "Lower Clothesline",
                    subtitle: "Lower the\nclothesline down",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 15,
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: 135,
      height: 160,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: const Color(0xFFD9E6F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF184B9B),
              size: 40,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF184B9B),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}