import 'package:flutter/material.dart';

class ConnectedDevicePage extends StatelessWidget {
  const ConnectedDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23),
          child: Column(
            children: [
              const SizedBox(height: 30),

              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF4B77FF),
                        size: 30,
                      ),
                    ),
                  ),
                  const Text(
                    'Connected Device',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF00307A),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 42),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select the device you want to use.\nThe device you select will be the active device.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF00307A),
                  ),
                ),
              ),

              const SizedBox(height: 38),

              const _DeviceCard(
                imagePath: 'assets/images/device.png',
                status: 'Online',
                statusColor: Color(0xFF3FCB62),
                statusBg: Color(0xFFD5F6DE),
                deviceId: 'CLP-7XC5BA',
                selected: true,
              ),

              const SizedBox(height: 19),

              const _DeviceCard(
                imagePath: 'assets/images/device.png',
                status: 'Offline',
                statusColor: Color(0xFF9D9D9D),
                statusBg: Color(0xFFE0E0E0),
                deviceId: 'CLP-7XC5BE',
                selected: false,
              ),

              const SizedBox(height: 24),

              Container(
                height: 36,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 23),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.add_rounded, color: Color(0xFF003E8F), size: 25),
                    SizedBox(width: 12),
                    Text(
                      'Add new device',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF003E8F),
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF003E8F),
                      size: 25,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 45),
                child: SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003E8F),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text(
                      'Remove Device',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
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

class _DeviceCard extends StatelessWidget {
  final String imagePath;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final String deviceId;
  final bool selected;

  const _DeviceCard({
    required this.imagePath,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.deviceId,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 67,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),

          Image.asset(imagePath, width: 48, height: 58, fit: BoxFit.contain),

          const SizedBox(width: 18),

          Expanded(
            child: Transform.translate(
              offset: const Offset(-19, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Device ID : $deviceId',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF777777),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 17),
            child: Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: const Color(0xFF003E8F),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
