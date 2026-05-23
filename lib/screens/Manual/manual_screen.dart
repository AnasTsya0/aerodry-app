import 'package:flutter/material.dart';
import 'package:aerodry_app/constants/app_state.dart';

class ManualScreen extends StatefulWidget {
  const ManualScreen({super.key});

  static const blueDark = Color(0xFF4E6EC4);
  static const blueLight = Color(0xFF74C0F3);

  @override
  State<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  bool _isStopped = false;
  late AnimationController _resetController;
  late Animation<double> _resetAnimation;

  static const double _thumbSize = 52;
  static const double _trackHPadding = 6;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _resetAnimation =
        Tween<double>(begin: 0, end: 0).animate(CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeOut,
    ));
    _resetController.addListener(() {
      setState(() => _dragPosition = _resetAnimation.value);
    });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  double _maxDrag(double trackWidth) =>
      trackWidth - _thumbSize - _trackHPadding * 2;

  double _progress(double trackWidth) {
    final max = _maxDrag(trackWidth);
    if (max <= 0) return 0;
    return (_dragPosition / max).clamp(0.0, 1.0);
  }

  void _onDragUpdate(DragUpdateDetails details, double trackWidth) {
    if (_isStopped) return;
    setState(() {
      _dragPosition =
          (_dragPosition + details.delta.dx).clamp(0, _maxDrag(trackWidth));
    });
  }

  void _onDragEnd(double trackWidth) {
    if (_isStopped) return;
    final progress = _progress(trackWidth);
    if (progress >= 0.85) {
      // Snap to end
      setState(() {
        _dragPosition = _maxDrag(trackWidth);
        _isStopped = true;
      });
      _showStoppedDialog();
    } else {
      // Animate back
      _resetAnimation =
          Tween<double>(begin: _dragPosition, end: 0).animate(CurvedAnimation(
        parent: _resetController,
        curve: Curves.easeOut,
      ));
      _resetController
        ..reset()
        ..forward();
    }
  }

  void _showStoppedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF34D399), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Process Stopped',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B3B7A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The clothesline operation has been\nsuccessfully stopped.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A8CA8),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    setState(() {
                      _isStopped = false;
                      _dragPosition = 0;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E6EC4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
          child: Column(
            children: [
             

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
        child: Padding(
          padding: EdgeInsets.only(right: 30),
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
    ),
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
                    onTap: () => RackState.moveOut(),
                    child: _controlButton(
                      image: 'assets/images/moveoutmanual.png',
                      title: "Move Out",
                      subtitle: "Move clothesline outside",
                      bgColor: const Color(0xFFDCE7FF),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: GestureDetector(
                    onTap: () => RackState.moveIn(),
                    child: _controlButton(
                      image: 'assets/images/moveinmanual.png',
                      title: "Move In",
                      subtitle: "Move clothesline inside",
                      bgColor: const Color(0xFFE9EDF3),
                    ),
                  ),
                ),
              ],
            ),

              const SizedBox(height: 30),

              // ─── Slide to Stop ───
              LayoutBuilder(
                builder: (context, constraints) {
                  final trackWidth = constraints.maxWidth;
                  final progress = _progress(trackWidth);

                  // Interpolate background from red to green
                  final bgColor = Color.lerp(
                    const Color(0xFFFFE6E6),
                    const Color(0xFFD1FAE5),
                    progress,
                  )!;
                  final borderColor = Color.lerp(
                    const Color(0xFFFF8B8B),
                    const Color(0xFF34D399),
                    progress,
                  )!;
                  final thumbColor = Color.lerp(
                    const Color(0xFFFF5B5B),
                    const Color(0xFF10B981),
                    progress,
                  )!;
                  final textColor = Color.lerp(
                    const Color(0xFFFF5252),
                    const Color(0xFF059669),
                    progress,
                  )!;
                  final subtitleColor = Color.lerp(
                    const Color(0xFFFF7A7A),
                    const Color(0xFF34D399),
                    progress,
                  )!;
                  final arrowColor = Color.lerp(
                    const Color(0xFFFF5B5B),
                    const Color(0xFF10B981),
                    progress,
                  )!;

                  return Container(
                    width: double.infinity,
                    height: 68,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: borderColor),
                    ),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Text content (fades out as you drag)
                        Positioned(
                          left: _thumbSize + _trackHPadding + 12,
                          right: 40,
                          child: Opacity(
                            opacity: (1 - progress * 1.8).clamp(0.0, 1.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Slide to stop the process",
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Slide to the right to stop the process",
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Arrow hint on right side
                        Positioned(
                          right: 14,
                          child: Opacity(
                            opacity: (1 - progress * 2).clamp(0.0, 1.0),
                            child: Icon(
                              Icons.keyboard_double_arrow_right_rounded,
                              color: arrowColor,
                            ),
                          ),
                        ),

                        // Draggable thumb
                        Positioned(
                          left: _trackHPadding + _dragPosition,
                          child: GestureDetector(
                            onHorizontalDragUpdate: (d) =>
                                _onDragUpdate(d, trackWidth),
                            onHorizontalDragEnd: (_) => _onDragEnd(trackWidth),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: _thumbSize,
                              height: _thumbSize,
                              decoration: BoxDecoration(
                                color: thumbColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: thumbColor.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isStopped
                                    ? Icons.check_rounded
                                    : Icons.stop_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

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
}) {
  return Container(
    width: 145,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
          ),
          child: Center(
            child: Image.asset(
              image,
              width: 62, // gedein icon jemuran keluar/masuk
              fit: BoxFit.contain,
            ),
          ),
        ),

        const SizedBox(height: 14), // title lebih deket ke icon

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF12376B),
            height: 1.1,
          ),
        ),

        const SizedBox(height: 3), // subtitle lebih deket ke title

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            height: 1.2,
            color: Color(0xFF7A8CA8),
          ),
        ),
      ],
    ),
  );
}
}

class _DryingCard extends StatelessWidget {
  const _DryingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
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
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DryingText(
                            icon: Icons.timer_outlined,
                            title: 'Drying Duration',
                            value: '35 Minutes',
                          ),
                          SizedBox(height: 10),
                          _DryingText(
                            icon: Icons.settings_outlined,
                            title: 'Mode',
                            value: 'Automatic',
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
                        child: const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: _BottomInfo(
                            icon: Icons.timer_outlined,
                            title: 'Last Update',
                            value: '9 : 15',
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
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: _BottomInfo(
                          icon: Icons.wb_sunny_outlined,
                          title: 'Weather Condition',
                          value: 'Clear Sky',
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