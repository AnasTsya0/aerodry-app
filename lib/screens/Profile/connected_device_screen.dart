import 'package:flutter/material.dart';
import 'package:aerodry_app/screens/profile/add_new_device_screen.dart';
import 'package:aerodry_app/constants/app_state.dart';

class ConnectedDevicePage extends StatefulWidget {
  const ConnectedDevicePage({super.key});

  static const Color blue = Color(0xFF0B4EA2);
  static const Color bg = Color(0xFFEAF3FF);

  @override
  State<ConnectedDevicePage> createState() => _ConnectedDevicePageState();
}

class _ConnectedDevicePageState extends State<ConnectedDevicePage> {
  // Local selection index — starts at global activeDeviceIndex
  late int selectedIndex;

  static const Color blue = Color(0xFF0B4EA2);
  static const Color bg = Color(0xFFEAF3FF);

  @override
  void initState() {
    super.initState();
    selectedIndex = activeDeviceIndex;
  }

  void _removeSelectedDevice() {
    if (deviceList.isEmpty) return;

    setState(() {
      deviceList.removeAt(selectedIndex);

      // Clamp activeDeviceIndex after removal
      if (deviceList.isEmpty) {
        activeDeviceIndex = 0;
        selectedIndex = 0;
      } else {
        selectedIndex = selectedIndex.clamp(0, deviceList.length - 1);
        activeDeviceIndex = selectedIndex;
      }
    });
  }

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

              // ── App bar ──
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

              const SizedBox(height: 24),

              // ── Device list ──
              if (deviceList.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 18),
                  child: Text(
                    'No devices yet. Add a new device below.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Column(
                  children: [
                    for (int i = 0; i < deviceList.length; i++) ...[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = i;
                            // Commit to global state immediately on tap
                            activeDeviceIndex = i;
                          });
                        },
                        child: _DeviceCard(
                          imagePath: 'assets/images/device.png',
                          name: deviceList[i].name,
                          location: deviceList[i].location,
                          // Online = whichever device is currently selected/active
                          status: selectedIndex == i ? 'Online' : 'Offline',
                          statusColor: selectedIndex == i
                              ? const Color(0xFF3FCB62)
                              : const Color(0xFF9D9D9D),
                          statusBg: selectedIndex == i
                              ? const Color(0xFFD5F6DE)
                              : const Color(0xFFE0E0E0),
                          selected: selectedIndex == i,
                        ),
                      ),
                      if (i < deviceList.length - 1) const SizedBox(height: 14),
                    ],
                  ],
                ),

              const SizedBox(height: 24),

              // ── Add new device button ──
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddNewDeviceScreen(),
                    ),
                  );
                  // Refresh list after returning from AddNewDeviceScreen
                  setState(() {
                    selectedIndex =
                        selectedIndex.clamp(0, (deviceList.length - 1).clamp(0, 99));
                  });
                },
                child: Container(
                  height: 42,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Row(
                    children: [
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

              // ── Info card ──
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
                child: const Row(
                  children: [
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

              // ── Remove selected device button ──
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: deviceList.isEmpty ? null : _removeSelectedDevice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF419AF5),
                      disabledBackgroundColor: const Color(0xFFBBD5F5),
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
      // No fixed height — let content breathe, prevents overflow
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: selected
            ? Border.all(color: ConnectedDevicePage.blue, width: 1.5)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(imagePath, width: 60, height: 60, fit: BoxFit.contain),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: ConnectedDevicePage.blue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
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

          const SizedBox(width: 8),

          Icon(
            selected
                ? Icons.check_circle_rounded
                : Icons.circle_outlined,
            color: ConnectedDevicePage.blue,
            size: 20,
          ),
        ],
      ),
    );
  }
}
