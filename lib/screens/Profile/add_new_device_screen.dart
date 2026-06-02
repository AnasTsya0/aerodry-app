import 'package:flutter/material.dart';
import 'package:aerodry_app/screens/profile/search_location_screen.dart';
import 'package:aerodry_app/constants/app_state.dart';

class AddNewDeviceScreen extends StatefulWidget {
  const AddNewDeviceScreen({super.key});

  @override
  State<AddNewDeviceScreen> createState() => _AddNewDeviceScreenState();
}

class _AddNewDeviceScreenState extends State<AddNewDeviceScreen> {
  final TextEditingController deviceController = TextEditingController();

  String selectedLocation = 'Bintaro, Jakarta City';

  @override
  void initState() {
    super.initState();
    // Listen to controller to rebuild button enabled/disabled state
    deviceController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    deviceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF3F95F4);
    const darkBlue = Color(0xFF0B3B7A);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 37),
          child: Column(
            children: [
              const SizedBox(height: 30),

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
                      child: Text(
                        'Add New Device',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: darkBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 22),
                ],
              ),
              const SizedBox(height: 32),

              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD5E7FF),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/device.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Create a new device to monitor\nclotheslines in different locations',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.25,
                  color: darkBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Device Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: darkBlue,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/device.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: TextField(
                        controller: deviceController,
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: 'Input device name',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: darkBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    GestureDetector(
                      onTap: () => deviceController.clear(),
                      child: const Icon(
                        Icons.cancel_outlined,
                        size: 15,
                        color: darkBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Example : House, Aero Dry',
                  style: TextStyle(fontSize: 13, color: Color(0xFF96A6B8)),
                ),
              ),

              const SizedBox(height: 14),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: darkBlue,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: blue,
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child: Text(
                        selectedLocation,
                        style: const TextStyle(
                          fontSize: 14,
                          color: darkBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchLocationScreen(),
                          ),
                        );

                        if (result != null && mounted) {
                          setState(() {
                            selectedLocation = result as String;
                          });
                        }
                      },
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: darkBlue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 45),

              SizedBox(
                width: 250,
                height: 50,
                child: ElevatedButton(
                  // Disabled when device name is empty
                  onPressed: deviceController.text.trim().isEmpty
                      ? null
                      : () {
                          final deviceName = deviceController.text.trim();

                          // Save to global device list
                          deviceList.add(DeviceModel(
                            name: deviceName,
                            location: selectedLocation,
                          ));

                          // Save location to saved addresses if new
                          if (!savedAddresses.contains(selectedLocation)) {
                            savedAddresses.add(selectedLocation);
                          }

                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F95F4),
                    disabledBackgroundColor: const Color(0xFFB0D4FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add New Device',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
