import 'package:flutter/material.dart';

class UpdatedLocationPage extends StatefulWidget {
  const UpdatedLocationPage({super.key});

  @override
  State<UpdatedLocationPage> createState() => _UpdatedLocationPageState();
}

class _UpdatedLocationPageState extends State<UpdatedLocationPage> {
  String selectedLocation = 'Tangerang, Indonesia';

  final List<Map<String, String>> locations = [
    {'city': 'Bandung, Indonesia', 'area': 'Jawa Barat'},
    {'city': 'Surabaya, Indonesia', 'area': 'Jawa Timur'},
    {'city': 'Padang, Indonesia', 'area': 'Sumatera Barat'},
    {'city': 'Bali, Indonesia', 'area': 'Denpasar'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            children: [
              const SizedBox(height: 16),

              /// HEADER
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF3D7CFF),
                      size: 20,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Updated Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF123C7C),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),

              const SizedBox(height: 38),

              /// SEARCH BAR
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Expanded(
                      child: Text(
                        'Search for the city',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF777777),
                        ),
                      ),
                    ),
                    Icon(Icons.search, color: Color(0xFF153F86), size: 24),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              /// CURRENT LOCATION CARD
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 32,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF143F88),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(7),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Current Location',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 11, 18, 11),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Tangerang, Indonesia',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          _radioButton('Tangerang, Indonesia'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              /// SELECT LOCATION CARD
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 32,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF143F88),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(7),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Select a new location',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    ...locations.map((item) {
                      final city = item['city']!;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedLocation = city;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 7, 18, 6),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFE5E5E5),
                                width: 0.8,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      city,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['area']!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _radioButton(city),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              const SizedBox(height: 34),

              /// INFO BOX
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF3D7CFF),
                      size: 20,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'The selected location will be used to adjust the\nweather information.',
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.15,
                          color: Color(0xFF143F88),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              /// BUTTON
              Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: SizedBox(
                  width: 216,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, selectedLocation);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text(
                      'Save Location',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF143F88),
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

  Widget _radioButton(String value) {
    final bool isSelected = selectedLocation == value;

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: const Color(0xFFCFE1FA),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFCFE1FA), width: 1),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF143F88),
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
