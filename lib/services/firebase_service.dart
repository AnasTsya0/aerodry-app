import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:aerodry_app/constants/app_state.dart';
import 'package:aerodry_app/constants/notification_state.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  late DatabaseReference _rootRef;
  String _uid = '';

  StreamSubscription? _statusSub;
  StreamSubscription? _controlSub;
  StreamSubscription? _sensorSub;
  StreamSubscription? _weatherSub;
  StreamSubscription? _activityLogSub;

  String _prevRackPosition = '';
  String _prevMotorStatus = '';
  bool _prevAlarmTriggered = false;
  bool _prevObstacle = false;
  int _prevRainValue = 4095;
  int _prevLdrValue = 0;
  int _prevIrValue = 1;
  bool _initialized = false;
  bool _sensorInitialized = false;
  String? _manualTarget;

  bool _manualInProgress = false;

  int _lastLdrValue = 0;
  int _lastRainValue = 4095;

  // Hysteresis
  static const int rainThreshold = 2500;
  static const int rainHysteresis = 200;
  static const int ldrThreshold = 1000;
  static const int ldrHysteresis = 200;

  DatabaseReference get _statusRef => _rootRef.child('status');
  DatabaseReference get _controlRef => _rootRef.child('control');
  DatabaseReference get _sensorRef => _rootRef.child('sensor');
  DatabaseReference get _weatherRef => _rootRef.child('weather_forecast');

  void init(String uid) {
    _uid = uid;
    _rootRef = FirebaseDatabase.instance.ref('JEMURAN/$_uid');
    _statusSub?.cancel();
    _controlSub?.cancel();
    _sensorSub?.cancel();
    _weatherSub?.cancel();
    _activityLogSub?.cancel();
    _listenStatus();
    _listenControl();
    _listenSensor();
    _listenWeather();
    _listenActivityLog();
  }

  void _listenStatus() {
    _statusSub = _statusRef.onValue.listen((event) async {
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
        final posisiBerubah = fbRackPosition != _prevRackPosition;

        if (posisiBerubah && _manualInProgress) {
          if (_manualTarget == fbRackPosition) {
            print('✅ [MANUAL] Selesai, posisi sesuai target $fbRackPosition');
          } else {
            print('⚠️ [MANUAL] Posisi tidak sesuai target, abaikan');
          }
          _manualInProgress = false;
          _manualTarget = null;
        }

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

  void _listenSensor() {
    _sensorSub = _sensorRef.onValue.listen((event) async {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return;
      final map = Map<String, dynamic>.from(data);

      final ir = (map['ir'] as int?) ?? 1;
      final rain = (map['rain'] as int?) ?? 4095;
      final ldr = (map['ldr'] as int?) ?? 4095;

      _lastLdrValue = ldr;
      _lastRainValue = rain;

      SecurityState.irSensor.value = ir;

      print('📊 [SENSOR] rain=$rain, ldr=$ldr, ir=$ir');

      if (!_sensorInitialized) {
        _prevRainValue = rain;
        _prevLdrValue = ldr;
        _prevIrValue = ir;
        _sensorInitialized = true;
        return;
      }

      // Jika sedang ada gerakan manual, jangan proses sensor
      if (_manualInProgress) {
        print('⏳ [SENSOR] Manual in progress, skip');
        _prevRainValue = rain;
        _prevLdrValue = ldr;
        _prevIrValue = ir;
        return;
      }

      // Rain detection with hysteresis
      if (_initialized &&
          rain < rainThreshold &&
          _prevRainValue > (rainThreshold + rainHysteresis)) {
        print('🌧️ [SENSOR] RAIN terdeteksi! rain=$rain');
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
      }

      if (_initialized &&
          rain >= rainThreshold &&
          _prevRainValue < (rainThreshold - rainHysteresis)) {
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

      // LDR detection with hysteresis
      if (_initialized &&
          ldr < ldrThreshold &&
          _prevLdrValue > (ldrThreshold + ldrHysteresis)) {
        print('☀️ [SENSOR] CAHAYA terdeteksi! ldr=$ldr');
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
      }

      if (_initialized &&
          ldr >= ldrThreshold &&
          _prevLdrValue < (ldrThreshold - ldrHysteresis)) {
        print('🌑 [SENSOR] GELAP terdeteksi! ldr=$ldr');
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
      }

      // Motion detection
      if (_initialized && ir == 0 && _prevIrValue != 0) {
        _addNotification(
          title: 'Motion Detected!',
          subtitle: 'Activity detected in the laundry area',
          img: 'assets/images/motioncard.png',
          sideColor: const Color(0xFFFF4444),
          titleColor: const Color(0xFFFF4444),
          iconBg: const Color(0xFFFFCACA),
        );
      }

      if (_initialized && ir != 0 && _prevIrValue == 0) {}

      _prevRainValue = rain;
      _prevLdrValue = ldr;
      _prevIrValue = ir;
    });
  }

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

  void _handleRackChange(String newPosition) {
    print('🔄 [RACK] posisi sekarang: $newPosition');
  }

  void _handleMotorChange(String newStatus) {}
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



  void _listenActivityLog() {
    _activityLogSub = FirebaseDatabase.instance
        .ref('JEMURAN/$_uid/activity_log')
        .orderByKey()
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data == null) {
        ActivityLogState.entries.value = [];
        return;
      }

      final Map<String, dynamic> map;
      if (data is Map) {
        map = Map<String, dynamic>.from(data);
      } else {
        ActivityLogState.entries.value = [];
        return;
      }

      final List<ActivityLogEntry> logEntries = [];

      for (final entry in map.entries) {
        try {
          final val = Map<String, dynamic>.from(entry.value as Map);
          final title = (val['title'] as String?) ?? '';
          final subtitle = (val['subtitle'] as String?) ?? (val['desc'] as String?) ?? '';
          final subtitle2 = (val['subtitle2'] as String?) ?? '';
          final tag = (val['tag'] as String?) ?? (val['type'] as String?) ?? 'Manual';
          final typeStr = (val['type'] as String?) ?? 'manual';
          final imagePath = (val['imagePath'] as String?) ?? 'assets/images/motioncard.png';
          final temp = (val['temp'] as String?) ?? '28°';
          final isRain = (val['isRain'] as bool?) ?? false;
          final location = (val['location'] as String?) ?? 'Jakarta';

          // Parse timestamp from key or from stored field
          int tsMs;
          if (val['timestamp'] != null) {
            tsMs = (val['timestamp'] as num).toInt();
          } else {
            tsMs = int.tryParse(entry.key) ?? DateTime.now().millisecondsSinceEpoch;
          }
          final timestamp = DateTime.fromMillisecondsSinceEpoch(tsMs);

          // Map type string to ActivityType enum
          ActivityType activityType;
          switch (typeStr.toLowerCase()) {
            case 'motion':
              activityType = ActivityType.motion;
              break;
            case 'weather':
              activityType = ActivityType.weather;
              break;
            case 'manual':
              activityType = ActivityType.manual;
              break;
            default:
              activityType = ActivityType.manual;
          }

          logEntries.add(ActivityLogEntry(
            title: title,
            subtitle1: subtitle,
            subtitle2: subtitle2,
            tag: tag,
            type: activityType,
            timestamp: timestamp,
            imagePath: imagePath,
            temp: temp,
            isRain: isRain,
            location: location,
          ));
        } catch (e) {
          print('⚠️ [ACTIVITY LOG] Error parsing entry: $e');
        }
      }

      // Sort by timestamp descending (newest first)
      logEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      ActivityLogState.entries.value = logEntries;
      print('📋 [ACTIVITY LOG] Loaded ${logEntries.length} entries from Firebase');
    });
  }

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

  // ─── Write methods ──────────────────────
  Future<void> sendMoveIn({bool manual = true}) async {
    print('🔴 sendMoveIn dipanggil: manual=$manual');
    if (manual) {
      _manualInProgress = true;
      _manualTarget = 'IN';
      print('🖐️ [MOVE IN] MANUAL - menunggu konfirmasi posisi');
    } else {
      print('🤖 [MOVE IN] otomatis diabaikan');
    }
    await _controlRef.update({'stop': false, 'moveIn': true, 'moveOut': false});
  }

  Future<void> sendMoveOut({bool manual = true}) async {
    print('🟢 sendMoveOut dipanggil: manual=$manual');
    if (manual) {
      _manualInProgress = true;
      _manualTarget = 'OUT';
      print('🖐️ [MOVE OUT] MANUAL - menunggu konfirmasi posisi');
    } else {
      print('🤖 [MOVE OUT] otomatis diabaikan');
    }
    await _controlRef.update({'stop': false, 'moveOut': true, 'moveIn': false});
  }

  Future<void> sendStop() async {
    _manualInProgress = false;
    _manualTarget = null; // batalkan target, tidak akan ada log
    await _controlRef.update({'stop': true, 'moveIn': false, 'moveOut': false});
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

  Future<void> setActivityNotifications(bool value) async {
    if (_uid.isEmpty) {
      print('❌ UID belum diinisialisasi.');
      return;
    }
    await FirebaseDatabase.instance
        .ref('JEMURAN/$_uid/security_settings')
        .update({'activityNotifications': value});
    print('✅ activityNotifications = $value terkirim');
  }

  Future<void> updateSecurityActionDelay(int seconds) async {
    if (_uid.isEmpty) return;
    await FirebaseDatabase.instance
        .ref('JEMURAN/$_uid/security_settings')
        .update({'actionDelay': seconds});
  }

  Future<bool> getSecurityAutoRetract() async {
    if (_uid.isEmpty) return false;
    final snapshot = await FirebaseDatabase.instance
        .ref('JEMURAN/$_uid/security_settings/autoRetract')
        .get();
    return snapshot.exists ? (snapshot.value as bool) : false;
  }

  Future<int> getSecurityActionDelay() async {
    if (_uid.isEmpty) return 5;
    final snapshot = await FirebaseDatabase.instance
        .ref('JEMURAN/$_uid/security_settings/actionDelay')
        .get();
    return snapshot.exists ? (snapshot.value as int) : 5;
  }

  void dispose() {
    _statusSub?.cancel();
    _controlSub?.cancel();
    _sensorSub?.cancel();
    _weatherSub?.cancel();
    _activityLogSub?.cancel();
  }
}
