import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:aerodry_app/constants/app_state.dart';
import 'package:aerodry_app/constants/notification_state.dart';

/// Singleton service that connects to Firebase Realtime Database,
/// listens to all nodes in real-time, and provides write methods
/// for controlling the clothesline hardware.
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  late DatabaseReference _rootRef;
  String _uid = '';

  // Stream subscriptions
  StreamSubscription? _statusSub;
  StreamSubscription? _controlSub;
  StreamSubscription? _sensorSub;
  StreamSubscription? _weatherSub;

  // Track previous values for generating activity log / notifications
  String _prevRackPosition = '';
  String _prevMotorStatus = '';
  bool _prevAlarmTriggered = false;
  bool _prevObstacle = false;
  int _prevRainValue = 4095;
  int _prevLdrValue = 0;
  int _prevIrValue = 1;
  bool _initialized = false;
  bool _sensorInitialized = false;

  String _lastTriggerSource = '';

  // ─── References ──────────────────────────────────────────────────────
  DatabaseReference get _statusRef => _rootRef.child('status');
  DatabaseReference get _controlRef => _rootRef.child('control');
  DatabaseReference get _sensorRef => _rootRef.child('sensor');
  DatabaseReference get _weatherRef => _rootRef.child('weather_forecast');

  // ─── Initialize ──────────────────────────────────────────────────────
  void init(String uid) {
    _uid = uid;
    _rootRef = FirebaseDatabase.instance.ref('JEMURAN/$_uid');

    _statusSub?.cancel();
    _controlSub?.cancel();
    _sensorSub?.cancel();
    _weatherSub?.cancel();

    _listenStatus();
    _listenControl();
    _listenSensor();
    _listenWeather();
  }

  // ─── Status listener ─────────────────────────────────────────────────
  void _listenStatus() {
    _statusSub = _statusRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return;
      final map = Map<String, dynamic>.from(data);

      final fbMode = (map['mode'] as String?) ?? 'AUTO';
      final fbDryingDuration = ((map['dryingDuration'] as num?) ?? 0).toInt();
      final fbMotorStatus = (map['motorStatus'] as String?) ?? 'STOP';
      final fbProgress = ((map['progress'] as num?) ?? 0).toInt();
      final fbRackPosition = (map['rackPosition'] as String?) ?? 'IN';
      final fbOnline = (map['online'] as bool?) ?? false;
      final fbObstacle = (map['obstacle'] as bool?) ?? false;
      final fbLastUpdate = ((map['lastUpdate'] as num?) ?? 0).toInt();

      DryingState.updateFromFirebase(
        fbMode: fbMode,
        fbDryingDuration: fbDryingDuration,
        fbMotorStatus: fbMotorStatus,
        fbProgress: fbProgress,
        fbRackPosition: fbRackPosition,
        fbOnline: fbOnline,
        fbObstacle: fbObstacle,
        fbLastUpdate: fbLastUpdate,
      );

      RackState.updateFromFirebase(fbRackPosition);

      if (_initialized) {
        _handleRackChange(fbRackPosition);
        _handleMotorChange(fbMotorStatus);
        _handleObstacleChange(fbObstacle);
      }

      _prevRackPosition = fbRackPosition;
      _prevMotorStatus = fbMotorStatus;
      _prevObstacle = fbObstacle;
      _initialized = true;
    });
  }

  // ─── Control listener ─────────────────────────────────────────────────
  void _listenControl() {
    _controlSub = _controlRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return;
      final map = Map<String, dynamic>.from(data);

      final fbSecurityMode = (map['securityMode'] as bool?) ?? true;
      final fbAlarmTriggered = (map['alarmTriggered'] as bool?) ?? false;

      SecurityState.updateFromFirebase(
        fbSecurityMode: fbSecurityMode,
        fbAlarmTriggered: fbAlarmTriggered,
      );

      if (_initialized && fbAlarmTriggered && !_prevAlarmTriggered) {
        _addNotification(
          title: 'Security Alert!',
          subtitle: 'Alarm triggered — motion detected near clothesline',
          img: 'assets/images/motioncard.png',
          sideColor: const Color(0xFFFF4444),
          titleColor: const Color(0xFFFF4444),
          iconBg: const Color(0xFFFFCACA),
        );
      }

      _prevAlarmTriggered = fbAlarmTriggered;
    });
  }

  // ─── Sensor listener ──────────────────────────────────────────────────
  void _listenSensor() {
    _sensorSub = _sensorRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return;
      final map = Map<String, dynamic>.from(data);

      final ir = (map['ir'] as int?) ?? 1;
      final rain = (map['rain'] as int?) ?? 4095;
      final ldr = (map['ldr'] as int?) ?? 4095;

      SecurityState.irSensor.value = ir;

      if (!_sensorInitialized) {
        _prevRainValue = rain;
        _prevLdrValue = ldr;
        _prevIrValue = ir;
        _sensorInitialized = true;
        return;
      }

      if (_initialized && rain < 1000 && _prevRainValue >= 1000) {
        _addNotification(
          title: 'Rain Detected',
          subtitle: 'Rain sensor triggered — clothesline retracting',
          img: 'assets/images/tutupjemurancard.png',
          sideColor: const Color(0xFF9EA3A7),
          titleColor: const Color(0xFF4A4A4A),
          iconBg: const Color(0xFFE5E5E5),
          isRain: true,
        );
        DryingState.onSensorTriggered(
          'Rain detected on rain sensor',
          sensorName: 'Rain Sensor',
        );
        _lastTriggerSource = 'RAIN';
        sendMoveIn(manual: false);
      }

      if (_initialized && rain >= 1000 && _prevRainValue < 1000) {
        _addNotification(
          title: 'Rain Stopped',
          subtitle: 'Rain sensor cleared — waiting for sunlight',
          img: 'assets/images/bukajemurancard.png',
          sideColor: const Color(0xFF5B7FFF),
          titleColor: const Color(0xFF4A4A4A),
          iconBg: const Color(0xFFDCE6FF),
          isRain: false,
        );
      }

      if (_initialized && ldr < 1000 && _prevLdrValue >= 1000) {
        _addNotification(
          title: 'Sunlight Detected',
          subtitle: 'LDR sensor triggered — clothesline extending',
          img: 'assets/images/bukajemurancard.png',
          sideColor: const Color(0xFF5B7FFF),
          titleColor: const Color(0xFF4A4A4A),
          iconBg: const Color(0xFFDCE6FF),
          isRain: false,
        );
        DryingState.onSensorTriggered(
          'Bright light detected by LDR sensor',
          sensorName: 'LDR Sensor',
        );
        _lastTriggerSource = 'LDR';
        sendMoveOut(manual: false);
      }

      if (_initialized && ldr >= 1000 && _prevLdrValue < 1000) {
        _addNotification(
          title: 'No Light Detected',
          subtitle: 'LDR sensor triggered — clothesline retracting',
          img: 'assets/images/tutupjemurancard.png',
          sideColor: const Color(0xFF9EA3A7),
          titleColor: const Color(0xFF4A4A4A),
          iconBg: const Color(0xFFE5E5E5),
          isRain: true,
        );
        DryingState.onSensorTriggered(
          'No light detected by LDR sensor',
          sensorName: 'LDR Sensor',
        );
        _lastTriggerSource = 'LDR';
        sendMoveIn(manual: false);
      }

      if (_initialized && ir == 0 && _prevIrValue != 0) {
        _addNotification(
          title: 'Motion Detected!',
          subtitle: 'Activity detected in the laundry area',
          img: 'assets/images/motioncard.png',
          sideColor: const Color(0xFFFF4444),
          titleColor: const Color(0xFFFF4444),
          iconBg: const Color(0xFFFFCACA),
        );
        ActivityLogState.addFirebaseEntry(
          title: 'Motion Detected',
          subtitle1: 'Activity detected in the laundry area',
          subtitle2: '',
          tag: 'Motion',
          type: ActivityType.motion,
          imagePath: 'assets/images/motioncard.png',
        );
      }

      if (_initialized && ir != 0 && _prevIrValue == 0) {
        ActivityLogState.addFirebaseEntry(
          title: 'No Motion Detected',
          subtitle1: 'Clothesline area is safe',
          subtitle2: '',
          tag: 'Motion',
          type: ActivityType.motion,
          imagePath: 'assets/images/motioncard.png',
        );
      }

      _prevRainValue = rain;
      _prevLdrValue = ldr;
      _prevIrValue = ir;
    });
  }

  // ─── Weather listener ─────────────────────────────────────────────────
  void _listenWeather() {
    _weatherSub = _weatherRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return;
      final map = Map<String, dynamic>.from(data);

      final condition = (map['condition'] as String?) ?? 'Clear Sky';
      final temp = (map['temp'] as int?) ?? 0;

      DryingState.weatherCondition.value = condition;
      if (temp > 0) {
        DryingState.temperature.value = '$temp°';
      }
    });
  }

  // ─── Event handlers ───────────────────────────────────────────────────
  void _handleRackChange(String newPosition) {
    if (newPosition == _prevRackPosition) return;
    final isOut = newPosition == 'OUT';
    final trigger = _lastTriggerSource;
    final isManual = trigger == 'MANUAL';

    String title, subtitle1, subtitle2, tag;
    ActivityType type;
    bool isRain = false;

    if (trigger == 'MANUAL') {
      title = isOut ? 'Extended Alert' : 'Retracted Alert';
      subtitle1 = isOut
          ? 'Clothesline moving out in manual mode'
          : 'Clothesline moving in in manual mode';
      subtitle2 = '';
      tag = 'Manual';
      type = ActivityType.manual;
    } else if (trigger == 'RAIN') {
      title = 'Retracted Alert';
      subtitle1 = 'Rain Detected';
      subtitle2 = '';
      tag = 'Weather';
      type = ActivityType.weather;
      isRain = true;
    } else if (trigger == 'LDR') {
      if (isOut) {
        title = 'Extended Alert';
        subtitle1 = 'Heat Warning Retracted';
        subtitle2 = '';
        tag = 'Weather';
        type = ActivityType.weather;
      } else {
        title = 'Retracted Alert';
        subtitle1 = 'No Light Detected';
        subtitle2 = '';
        tag = 'Weather';
        type = ActivityType.weather;
        isRain = true;
      }
    } else {
      title = isOut ? 'Extended Alert' : 'Retracted Alert';
      subtitle1 = isOut ? 'Clothesline Moving Out' : 'Clothesline Moving In';
      subtitle2 = '';
      tag = 'Weather';
      type = ActivityType.weather;
      isRain = !isOut;
    }

    ActivityLogState.addFirebaseEntry(
      title: title,
      subtitle1: subtitle1,
      subtitle2: subtitle2,
      tag: tag,
      type: type,
      imagePath: isOut
          ? 'assets/images/moveoutmanual.png'
          : 'assets/images/moveinmanual.png',
      temp: DryingState.temperature.value,
      isRain: isRain,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _lastTriggerSource = '';
    });

    _addNotification(
      title: isOut ? 'Extended Alert' : 'Retracted Alert',
      subtitle: isOut
          ? 'Clothesline has been moved out'
          : 'Clothesline has been moved in',
      img: isOut
          ? 'assets/images/bukajemurancard.png'
          : 'assets/images/tutupjemurancard.png',
      sideColor: isOut ? const Color(0xFF5B7FFF) : const Color(0xFF9EA3A7),
      titleColor: const Color(0xFF4A4A4A),
      iconBg: isOut ? const Color(0xFFDCE6FF) : const Color(0xFFE5E5E5),
    );
  }

  void _handleMotorChange(String newStatus) {
    // nothing needed
  }

  void _handleObstacleChange(bool newObstacle) {
    if (newObstacle == _prevObstacle) return;
    if (newObstacle) {
      _addNotification(
        title: 'Obstacle Detected!',
        subtitle: 'Obstacle detected — motor stopped for safety',
        img: 'assets/images/motioncard.png',
        sideColor: const Color(0xFFFF8800),
        titleColor: const Color(0xFFFF8800),
        iconBg: const Color(0xFFFFE4C4),
      );
    }
  }

  // ─── Notification helper ──────────────────────────────────────────────
  void _addNotification({
    required String title,
    required String subtitle,
    required String img,
    required Color sideColor,
    required Color titleColor,
    required Color iconBg,
    bool isRain = false,
  }) {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final location = deviceList.isNotEmpty
        ? deviceList[activeDeviceIndex].location
        : 'Jakarta';
    final city = location.split(',').first.trim();

    NotificationState.addNotification(
      NotificationEntry(
        title: title,
        subtitle: subtitle,
        temperature: DryingState.temperature.value,
        city: city,
        img: img,
        sideColor: sideColor,
        titleColor: titleColor,
        iconBg: iconBg,
        isRain: isRain,
        timestamp: now,
      ),
    );
  }

  // ─── Write methods (control the hardware) ─────────────────────────────
  Future<void> sendMoveIn({bool manual = true}) async {
    await _controlRef.update({
      'stop': false,
      'moveIn': true,
      'moveOut': false,
    });
  }

  Future<void> sendMoveOut({bool manual = true}) async {
    await _controlRef.update({
      'stop': false,
      'moveOut': true,
      'moveIn': false,
    });
  }

  Future<void> sendStop() async {
    await _controlRef.update({
      'stop': true,
      'moveIn': false,
      'moveOut': false,
    });
  }

  Future<void> setAutoMode(bool value) async {
    await _controlRef.update({'autoMode': value});
  }

  Future<void> setSecurityMode(bool value) async {
    await _controlRef.update({'securityMode': value});
  }

  Future<void> setIzinkanJemur(bool value) async {
    await _controlRef.update({'izinkanJemur': value});
  }

  Future<void> resetAlarm() async {
    await _controlRef.update({'alarmTriggered': false});
  }

  // ─── Security settings (for SecurityScreen) ─────────────────────────
  Future<void> setSecurityAutoRetract(bool value) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseDatabase.instance
        .ref('JEMURAN/$uid/security_settings')
        .update({'autoRetract': value});
  }

  Future<void> updateSecurityActionDelay(int seconds) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseDatabase.instance
        .ref('JEMURAN/$uid/security_settings')
        .update({'actionDelay': seconds});
  }

  Future<bool> getSecurityAutoRetract() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseDatabase.instance
        .ref('JEMURAN/$uid/security_settings/autoRetract')
        .get();
    return snapshot.exists ? (snapshot.value as bool) : false;
  }

  Future<int> getSecurityActionDelay() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseDatabase.instance
        .ref('JEMURAN/$uid/security_settings/actionDelay')
        .get();
    return snapshot.exists ? (snapshot.value as int) : 5;
  }

  /// Dispose all listeners
  void dispose() {
    _statusSub?.cancel();
    _controlSub?.cancel();
    _sensorSub?.cancel();
    _weatherSub?.cancel();
  }
}