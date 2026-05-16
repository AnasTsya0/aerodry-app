import 'package:flutter/material.dart';
import 'package:aerodry_app/screens/profile/add_new_device_screen.dart';

class ConnectedDevicePage extends StatefulWidget {
  const ConnectedDevicePage({super.key});

  static const Color blue = Color(0xFF0B4EA2);
  static const Color bg = Color(0xFFEAF3FF);

  @override
  State<ConnectedDevicePage> createState() => _ConnectedDevicePageState();
}

class _ConnectedDevicePageState extends State<ConnectedDevicePage> {
  int selectedDevice = 0;

  static const Color blue = Color(0xFF0B4EA2);
  static const Color bg = Color(0xFFEAF3FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 33),
          child: Column(
            children: [
              const SizedBox(height: 30),

              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF2B6BFF),
                      size: 30,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Connected Device',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 22),
                ],
              ),

              const SizedBox(height: 58),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select the device you want to use.\nThe device you select will be the active device.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: blue,
                  ),
                ),
              ),

              const SizedBox(height: 42),

              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDevice = 0;
                  });
                },
                child: _DeviceCard(
                  imagePath: 'assets/images/device.png',
                  name: 'House, Aero Dry',
                  location: 'Tangerang, House',
                  status: 'Online',
                  statusColor: Color(0xFF3FCB62),
                  statusBg: Color(0xFFD5F6DE),
                  selected: selectedDevice == 0,
                ),
              ),
              const SizedBox(height: 14),

              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDevice = 1;
                  });
                },
                child: _DeviceCard(
                  imagePath: 'assets/images/device.png',
                  name: 'Boarding House, Aero Dry',
                  location: 'Jakarta, Boarding House',
                  status: 'Offline',
                  statusColor: Color(0xFF9D9D9D),
                  statusBg: Color(0xFFE0E0E0),
                  selected: selectedDevice == 1,
                ),
              ),

              const SizedBox(height: 24),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddNewDeviceScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 42,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.add_rounded, color: blue, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Add new device',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: blue,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.chevron_right_rounded, color: blue, size: 24),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline_rounded, color: blue, size: 19),
                    SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        'This device will monitor weather conditions and\nhelp control the drying of clothes at that location.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.25,
                          fontWeight: FontWeight.w500,
                          color: blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF419AF5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text(
                      'Remove Device',
                      style: TextStyle(
                        fontSize: 15,
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
  final String name;
  final String location;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final bool selected;

  const _DeviceCard({
    required this.imagePath,
    required this.name,
    required this.location,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          Image.asset(imagePath, width: 60, height: 69, fit: BoxFit.contain),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: ConnectedDevicePage.blue,
                  ),
                ),
                const SizedBox(height: 0),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ConnectedDevicePage.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 0),

          Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: ConnectedDevicePage.blue,
            size: 20,
          ),
        ],
      ),
    );
  }
}
