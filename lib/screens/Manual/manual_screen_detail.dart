import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:aerodry_app/constants/app_state.dart';
import 'package:aerodry_app/services/weather_service.dart';
import 'package:aerodry_app/services/firebase_service.dart';

class ManualDetailScreen extends StatefulWidget {
  final String moveType; // 'out' or 'in'

  const ManualDetailScreen({super.key, required this.moveType});

  static const blueDark = Color(0xFF4E6EC4);
  static const blueLight = Color(0xFF74C0F3);

  @override
  State<ManualDetailScreen> createState() => _ManualDetailScreenState();
}

class _ManualDetailScreenState extends State<ManualDetailScreen>
    with TickerProviderStateMixin {
  // ─── Progress from Firebase ───
  bool _isProcessing = true;
  bool _isCancelled = false;
  bool _obstacleDetected = false;
  bool _motorStarted = false;

  // ─── Slide to cancel ───
  double _dragPosition = 0;
  late AnimationController _resetController;
  late Animation<double> _resetAnimation;

  // ─── Weather label fetched on init ───
  String _weatherLabel = 'Clear Sky';
  String _deviceTemperature = '--°';

  static const double _thumbSize = 52;
  static const double _trackHPadding = 6;

  @override
  void initState() {
    super.initState();

    // Reset progress to 0 locally so that the screen starts displaying 0% immediately
    DryingState.progress.value = 0;
    // Fetch live weather label in background
    _fetchWeatherLabel();

    // Listen to Firebase progress and motor status
    DryingState.progress.addListener(_onProgressChange);
    DryingState.motorStatus.addListener(_onMotorChange);
    DryingState.obstacle.addListener(_onObstacleChange);

    // Slide reset animation
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _resetAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(parent: _resetController, curve: Curves.easeOut));
    _resetController.addListener(() {
      setState(() => _dragPosition = _resetAnimation.value);
    });

    // Send the Firebase command to move the hardware
    _sendCommand();
  }

  Future<void> _sendCommand() async {
    if (widget.moveType == 'out') {
      await FirebaseService.instance.sendMoveOut();
    } else {
      await FirebaseService.instance.sendMoveIn();
    }
  }

  Future<void> _fetchWeatherLabel() async {
    try {
      final location = deviceList.isNotEmpty
          ? deviceList[activeDeviceIndex].location
          : 'Tangerang';
      final data = await WeatherService.fetchForLocation(location);
      if (mounted) {
        setState(() {
          _weatherLabel = WeatherCodeHelper.label(
            data.current.weatherCode,
            windSpeed: data.current.windSpeed,
          );
          _deviceTemperature = '${data.current.temperature}°';
        });
      }
    } catch (_) {
      // Keep default 'Clear Sky' on failure
    }
  }

  @override
  void dispose() {
    DryingState.progress.removeListener(_onProgressChange);
    DryingState.motorStatus.removeListener(_onMotorChange);
    DryingState.obstacle.removeListener(_onObstacleChange);
    _resetController.dispose();
    super.dispose();
  }

  void _onProgressChange() {
    print("Progress = ${DryingState.progress.value}");
    print("Motor = ${DryingState.motorStatus.value}");
    if (!mounted || _isCancelled) return;

    setState(() {});
  }

  void _onMotorChange() {
  if (!mounted || _isCancelled) return;
  final motor = DryingState.motorStatus.value;
  if (motor == 'MOVING_OUT' || motor == 'MOVING_IN') {
    _motorStarted = true;
    _isProcessing = true;   // pastikan processing true
  }
  if (motor == 'STOP' && _isProcessing && DryingState.progress.value < 96) {
    // Berhenti tidak sempurna → cancel (di bawah 96% dianggap gagal)
    _isProcessing = false;
    _isCancelled = true;
    _showCancelledDialog();
}
  if (_motorStarted && motor == 'STOP' && DryingState.progress.value >= 96 && _isProcessing) {
    _onProcessComplete();
  }
}

 void _onObstacleChange() {
    if (!mounted || _isCancelled) return;
    if (DryingState.obstacle.value && _isProcessing) {
        // Kirim perintah stop agar motor berhenti
        FirebaseService.instance.sendStop();
        setState(() {
            _obstacleDetected = true;
            _isProcessing = false;
        });
        _showObstacleDialog();
    }
}

  // ─── Process completion ───
  void _onProcessComplete() {
    if (!mounted || !_isProcessing) return;
    setState(() => _isProcessing = false);
    // Get active device location
    final deviceLocation = deviceList.isNotEmpty
        ? deviceList[activeDeviceIndex].location
        : 'Unknown';
    // Update global drying state ONLY on success
    DryingState.onManualSuccess(
      moveType: widget.moveType,
      weatherLabel: _weatherLabel,
      deviceLocation: deviceLocation,
      deviceTemperature: _deviceTemperature,
    );
    // Update rack state based on move type
    if (widget.moveType == 'out') {
      RackState.moveOut();
    } else {
      RackState.moveIn();
    }
    _showSuccessDialog();
  }

  // ─── Cancel process — just stop immediately ───
  void _onCancelProcess() async {
    // Send stop command to Firebase
    await FirebaseService.instance.sendStop();
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _isCancelled = true;
    });
    // Do NOT update DryingState or RackState on cancel
    _showCancelledDialog();
  }

  // ─── Obstacle dialog ───
  void _showObstacleDialog() {
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
                    colors: [Color(0xFFFF8800), Color(0xFFFF6600)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Obstacle Detected',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B3B7A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'An obstacle was detected in the\nclothesline path. Motor has been\nstopped for safety.',
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
                    Navigator.of(context).pop(false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8800),
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

  // ─── Success dialog (process reached 100%) ───
  void _showSuccessDialog() {
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
                'Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B3B7A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.moveType == 'out'
                    ? 'Clothesline has been extended\nsuccessfully. Happy drying!'
                    : 'Clothesline has been retracted\nsuccessfully. All safe!',
                textAlign: TextAlign.center,
                style: const TextStyle(
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
                    Navigator.of(ctx).pop(); // close dialog
                    Navigator.of(context).pop(true); // success → pop with true
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

  // ─── Cancelled dialog (user slid to cancel) ───
  void _showCancelledDialog() {
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
                    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.cancel_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Process Cancelled',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0B3B7A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The clothesline operation has been\nsuccessfully cancelled.',
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
                    Navigator.of(ctx).pop(); // close dialog
                    Navigator.of(
                      context,
                    ).pop(false); // cancelled → pop with false
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

  // ─── Slide drag helpers ───
  double _maxDrag(double trackWidth) =>
      trackWidth - _thumbSize - _trackHPadding * 2;

  double _slideProgress(double trackWidth) {
    final max = _maxDrag(trackWidth);
    if (max <= 0) return 0;
    return (_dragPosition / max).clamp(0.0, 1.0);
  }

  void _onDragUpdate(DragUpdateDetails details, double trackWidth) {
    if (_isCancelled || !_isProcessing) return;
    setState(() {
      _dragPosition = (_dragPosition + details.delta.dx).clamp(
        0,
        _maxDrag(trackWidth),
      );
    });
  }

  void _onDragEnd(double trackWidth) {
    if (_isCancelled || !_isProcessing) return;
    final progress = _slideProgress(trackWidth);
    if (progress >= 0.85) {
      setState(() {
        _dragPosition = _maxDrag(trackWidth);
      });
      _onCancelProcess();
    } else {
      // Animate back to start
      _resetAnimation = Tween<double>(begin: _dragPosition, end: 0).animate(
        CurvedAnimation(parent: _resetController, curve: Curves.easeOut),
      );
      _resetController
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final int percent = DryingState.progress.value.clamp(0, 100);
    final bool isMoveOut = widget.moveType == 'out';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
          child: Column(
            children: [
              // ─── Header ───
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

                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            isMoveOut ? 'Move Out' : 'Move In',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0B3B7A),
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isMoveOut
                                ? "Moving the clothesline out"
                                : "Moving the clothesline in",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
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

              const _DryingStatusCard(),

              const SizedBox(height: 30),

              // ─── Process Progress Card ───
              _buildProcessCard(percent, isMoveOut),

              const SizedBox(height: 18),

              // ─── Slide to Cancel (only visible during process) ───
              if (_isProcessing) _buildSlideToCancel(),

              if (_isProcessing) const SizedBox(height: 18),

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

  // ─── Process card with dynamic circular progress ───
  Widget _buildProcessCard(int percent, bool isMoveOut) {
    final String processTitle = isMoveOut
        ? 'Move Out Process'
        : 'Move In Process';
    final String processMessage = _isProcessing
        ? (isMoveOut
              ? 'Please wait while the clothesline is moving out'
              : 'Please wait while the clothesline is moving in')
        : 'Process completed successfully';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            processTitle,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B3B7A),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 150,
            height: 150,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percent / 100.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              builder: (context, value, _) {
                // Dot position on circular arc based on interpolated value
                final double angle = -math.pi / 2 + 2 * math.pi * value;
                const double arcRadius = 67.5;
                const double cx = 75.0;
                const double cy = 75.0;
                const double dotR = 9.0;
                final double dotX = cx + arcRadius * math.cos(angle) - dotR;
                final double dotY = cy + arcRadius * math.sin(angle) - dotR;

                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Circular progress with smooth animation
                    SizedBox(
                      width: 145,
                      height: 145,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 10,
                        backgroundColor: const Color(0xFFE6EDF7),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _obstacleDetected
                              ? const Color(0xFFFF8800)
                              : const Color(0xFF4B8FFF),
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    // Tracking dot on the arc
                    if (value > 0.01)
                      Positioned(
                        left: dotX,
                        top: dotY,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _obstacleDetected
                                  ? const Color(0xFFFF8800)
                                  : const Color(0xFF64A8FF),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4B8FFF).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Center text
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(value * 100).toInt()}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1976D2),
                            height: 1,
                          ),
                        ),
                        const Text(
                          '%',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _obstacleDetected
                              ? 'Obstacle!'
                              : (_isProcessing ? 'In Progress' : 'Completed'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _obstacleDetected
                                ? const Color(0xFFFF8800)
                                : (_isProcessing
                                      ? const Color(0xFF1976D2)
                                      : const Color(0xFF10B981)),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: _obstacleDetected
                  ? const Color(0xFFFFE4C4)
                  : const Color(0xFFD9ECFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _obstacleDetected
                  ? 'Obstacle detected — motor stopped for safety'
                  : processMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _obstacleDetected
                    ? const Color(0xFFCC6600)
                    : const Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Slide to Cancel widget ───
  Widget _buildSlideToCancel() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final progress = _slideProgress(trackWidth);

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
                        "Slide to cancel the process",
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Slide to the right to cancel",
                        style: TextStyle(color: subtitleColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
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
              Positioned(
                left: _trackHPadding + _dragPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) => _onDragUpdate(d, trackWidth),
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
                    child: const Icon(
                      Icons.stop_rounded,
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
    );
  }
}

// ─── Drying Status Card (matches Dashboard) ───
class _DryingStatusCard extends StatefulWidget {
  const _DryingStatusCard();

  @override
  State<_DryingStatusCard> createState() => _DryingStatusCardState();
}

class _DryingStatusCardState extends State<_DryingStatusCard> {
  @override
  void initState() {
    super.initState();
    DryingState.displayMode.addListener(_onStateChange);
    DryingState.lastUpdateTime.addListener(_onStateChange);
    DryingState.weatherCondition.addListener(_onStateChange);
    DryingState.dryingDurationMinutes.addListener(_onStateChange);
    DryingState.dryingStartTime.addListener(_onStateChange);
    DryingState.online.addListener(_onStateChange);
  }

  @override
  void dispose() {
    DryingState.displayMode.removeListener(_onStateChange);
    DryingState.lastUpdateTime.removeListener(_onStateChange);
    DryingState.weatherCondition.removeListener(_onStateChange);
    DryingState.dryingDurationMinutes.removeListener(_onStateChange);
    DryingState.dryingStartTime.removeListener(_onStateChange);
    DryingState.online.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mode = DryingState.displayMode.value;
    final lastUpdate = DryingState.formattedLastUpdate;
    final weatherCond = DryingState.weatherCondition.value;
    final dryingDuration = DryingState.formattedDryingDuration;
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ManualDetailScreen.blueDark, ManualDetailScreen.blueLight],
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
                      color: DryingState.online.value
                          ? const Color.fromARGB(255, 3, 55, 30)
                          : const Color.fromARGB(255, 60, 60, 60),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 2,
                          backgroundColor: DryingState.online.value
                              ? const Color(0xFF42EF7D)
                              : const Color(0xFF9E9E9E),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          DryingState.online.value ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: DryingState.online.value
                                ? const Color.fromARGB(255, 4, 170, 57)
                                : const Color(0xFF9E9E9E),
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
                            icon: Icons.timer_outlined,
                            title: 'Last Update',
                            value: lastUpdate,
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
                          title: 'Weather Condition',
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
