import 'package:flutter/material.dart';
import 'dart:async';
import 'package:aerodry_app/constants/app_state.dart';
import 'package:aerodry_app/screens/Manual/manual_screen_detail.dart';

class ManualScreen extends StatefulWidget {
  const ManualScreen({super.key});

  static const blueDark = Color(0xFF4E6EC4);
  static const blueLight = Color(0xFF74C0F3);

  @override
  State<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  String selectedMove = '';

  Future<void> _navigateToDetail(String moveType) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ManualDetailScreen(moveType: moveType),
      ),
    );
    // If cancelled or dismissed, reset selection
    if (result != true && mounted) {
      setState(() => selectedMove = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
          child: Column(
            children: [

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
                            'Manual Control',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0B3B7A),
                              height: 1,
                            ),
                          ),

                          SizedBox(height: 6),

                          Text(
                            "Control the clothesline manually",
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

              const SizedBox(height: 30),

              const _DryingCard(),

              const SizedBox(height: 35),

              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.blueGrey.withOpacity(0.2),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "Control",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF12376B),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.blueGrey.withOpacity(0.2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => selectedMove = 'out');
                        _navigateToDetail('out');
                      },
                      child: _controlButton(
                        image: 'assets/images/moveoutmanual.png',
                        title: "Move Out",
                        subtitle: "Move the clothesline\nout for drying",
                        bgColor: const Color(0xFFDCE7FF),
                        isSelected: selectedMove == 'out',
                        isMoveIn: false,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => selectedMove = 'in');
                        _navigateToDetail('in');
                      },
                      child: _controlButton(
                        image: 'assets/images/moveinmanual.png',
                        title: "Move In",
                        subtitle: "Move the clothesline\nin after drying",
                        bgColor: const Color(0xFFE9EDF3),
                        isSelected: selectedMove == 'in',
                        isMoveIn: true,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF5A8DFF),
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Make sure the area is clear before operating !",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7A99),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _controlButton({
    required String image,
    required String title,
    required String subtitle,
    required Color bgColor,
    required bool isSelected,
    required bool isMoveIn,
  }) {
    final Color activeBg =
        isMoveIn ? const Color(0xFFD7DCDF) : const Color(0xFFCFE0FF);

    final Color activeBorder =
        isMoveIn ? const Color(0xFF9EA8AD) : const Color(0xFF6FA0FF);

    final Color circleColor = isSelected
        ? (isMoveIn ? const Color(0xFFC2C8CB) : const Color(0xFFB8CDFF))
        : bgColor;

    return Container(
      width: 145,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? activeBg : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? activeBorder : Colors.transparent,
          width: 1.4,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
            ),
            child: Center(
              child: Image.asset(
                image,
                width: 55,
                fit: BoxFit.contain,
                color: isSelected && isMoveIn ? Colors.grey : null,
                colorBlendMode:
                    isSelected && isMoveIn ? BlendMode.srcIn : null,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B3B7A),
              height: 1,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              height: 1.15,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DryingCard extends StatefulWidget {
  const _DryingCard();

  @override
  State<_DryingCard> createState() => _DryingCardState();
}

class _DryingCardState extends State<_DryingCard> {
  Timer? _durationTimer;

  @override
  void initState() {
    super.initState();
    DryingState.mode.addListener(_onStateChange);
    DryingState.lastUpdateTime.addListener(_onStateChange);
    DryingState.weatherCondition.addListener(_onStateChange);
    DryingState.location.addListener(_onStateChange);
    DryingState.temperature.addListener(_onStateChange);
    DryingState.dryingStartTime.addListener(_onDryingTimeChange);
    _startDurationTimer();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    DryingState.mode.removeListener(_onStateChange);
    DryingState.lastUpdateTime.removeListener(_onStateChange);
    DryingState.weatherCondition.removeListener(_onStateChange);
    DryingState.location.removeListener(_onStateChange);
    DryingState.temperature.removeListener(_onStateChange);
    DryingState.dryingStartTime.removeListener(_onDryingTimeChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _onDryingTimeChange() {
    _startDurationTimer();
    if (mounted) setState(() {});
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    if (DryingState.dryingStartTime.value != null) {
      _durationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = DryingState.mode.value;
    final lastUpdate = DryingState.formattedLastUpdate;
    final weatherCond = DryingState.weatherCondition.value;
    final dryingDuration = DryingState.formattedDryingDuration;
    final location = DryingState.location.value;
    final temperature = DryingState.temperature.value;

    return Container(
      height: 240,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ManualScreen.blueDark, ManualScreen.blueLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 9),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const SizedBox(width: 58),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Drying Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(-4, 9),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 3, 55, 30),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 2,
                          backgroundColor: Color(0xFF42EF7D),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Color.fromARGB(255, 4, 170, 57),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 60),
                  Transform.translate(
                    offset: const Offset(0, 3),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Image.asset(
                            'assets/images/jemurandry.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DryingText(
                            icon: Icons.timer_outlined,
                            title: 'Drying Duration',
                            value: dryingDuration,
                          ),
                          const SizedBox(height: 10),
                          _DryingText(
                            icon: Icons.settings_outlined,
                            title: 'Mode',
                            value: mode,
                          ),
                          const SizedBox(height: 10),
                          _DryingText(
                            icon: Icons.thermostat_outlined,
                            title: 'Temperature',
                            value: temperature,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -5),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.14),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Transform.translate(
                        offset: const Offset(-20, 0),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: _BottomInfo(
                            icon: Icons.location_on_outlined,
                            title: 'Location',
                            value: location,
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(-12, 0),
                      child: const SizedBox(
                        height: 22,
                        child: VerticalDivider(
                          color: Colors.white30,
                          width: 1,
                          thickness: 1,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _BottomInfo(
                          icon: Icons.wb_sunny_outlined,
                          title: 'Weather',
                          value: weatherCond,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DryingText extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DryingText({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 25),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                height: 1.05,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BottomInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _BottomInfo({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
