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

  /// When a sensor overrides weatherCondition, skip Firebase weather updates
  /// for a short period so the sensor value stays visible.
  DateTime? _sensorOverrideUntil;

  /// Track known activity log keys to detect new entries
  Set<String>? _knownActivityKeys;

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
        // Security alert — notification handled via activity log
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
        // Set initial weatherCondition based on current sensor state
        if (rain < rainThreshold) {
          DryingState.weatherCondition.value = 'Rain';
          print('🌧️ [SENSOR INIT] Rain already active, setting condition=Rain');
        } else if (ldr >= ldrThreshold) {
          DryingState.weatherCondition.value = 'No Light';
          print('🌑 [SENSOR INIT] No light already active, setting condition=No Light');
        } else if (ldr < ldrThreshold) {
          DryingState.weatherCondition.value = 'Sunny';
          print('☀️ [SENSOR INIT] Sunny already active, setting condition=Sunny');
        }
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
        DryingState.onSensorTriggered(
          'Rain detected on rain sensor',
          sensorName: 'Rain Sensor',
        );
      }

      if (_initialized &&
          rain >= rainThreshold &&
          _prevRainValue < (rainThreshold - rainHysteresis)) {
        DryingState.onSensorTriggered(
          'Rain stopped, waiting for sunlight',
          sensorName: 'Rain Sensor',
        );
      }

      // LDR detection with hysteresis
      if (_initialized &&
          ldr < ldrThreshold &&
          _prevLdrValue > (ldrThreshold + ldrHysteresis)) {
        print('☀️ [SENSOR] CAHAYA terdeteksi! ldr=$ldr');
        DryingState.onSensorTriggered(
          'Bright light detected by LDR sensor',
          sensorName: 'LDR Sensor',
        );
      }

      if (_initialized &&
          ldr >= ldrThreshold &&
          _prevLdrValue < (ldrThreshold - ldrHysteresis)) {
        print('🌑 [SENSOR] GELAP terdeteksi! ldr=$ldr');
        DryingState.onSensorTriggered(
          'No light detected by LDR sensor',
          sensorName: 'LDR Sensor',
        );
      }

      // Motion detection — notification handled via activity log
      if (_initialized && ir == 0 && _prevIrValue != 0) {
        // motion event logged; notification comes from _createNotificationFromLogEntry
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

      // Only update temperature — weatherCondition is derived from activity log
      final temp = (map['temp'] as int?) ?? 0;
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
    // Obstacle detected (no notification)
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
          int tsRaw;
          if (val['timestamp'] != null) {
            tsRaw = (val['timestamp'] as num).toInt();
          } else {
            tsRaw = int.tryParse(entry.key) ?? DateTime.now().millisecondsSinceEpoch;
          }
          // Auto-detect seconds vs milliseconds:
          // If value < 10000000000 (Sep 2001 in ms, or year 2286 in sec),
          // it's likely seconds → convert to ms
          final int tsMs = tsRaw < 10000000000 ? tsRaw * 1000 : tsRaw;
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

          // Always use current active device location (not stale Firebase value)
          final activeLocation = deviceList.isNotEmpty
              ? deviceList[activeDeviceIndex].location
              : location;
          // Use live temperature if available, fallback to stored value
          final activeTemp = DryingState.temperature.value.isNotEmpty &&
                  DryingState.temperature.value != '--°'
              ? DryingState.temperature.value
              : temp;

          logEntries.add(ActivityLogEntry(
            title: title,
            subtitle1: subtitle,
            subtitle2: subtitle2,
            tag: tag,
            type: activityType,
            timestamp: timestamp,
            imagePath: imagePath,
            temp: activeTemp,
            isRain: isRain,
            location: activeLocation,
          ));
        } catch (e) {
          print('⚠️ [ACTIVITY LOG] Error parsing entry: $e');
        }
      }

      // Sort by timestamp descending (newest first)
      logEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Generate notifications for NEW entries only (not on initial load)
      final newKeys = map.keys.toSet();
      if (_knownActivityKeys != null) {
        final addedKeys = newKeys.difference(_knownActivityKeys!);
        if (addedKeys.isNotEmpty) {
          for (final key in addedKeys) {
            // Find the matching log entry
            final entry = logEntries.where((e) {
              int tsRaw;
              if ((map[key] as Map)['timestamp'] != null) {
                tsRaw = ((map[key] as Map)['timestamp'] as num).toInt();
              } else {
                tsRaw = int.tryParse(key) ?? 0;
              }
              final tsMs = tsRaw < 10000000000 ? tsRaw * 1000 : tsRaw;
              return e.timestamp.millisecondsSinceEpoch == tsMs;
            }).firstOrNull;

            if (entry != null) {
              _createNotificationFromLogEntry(entry);
            }
          }
        }
      }
      _knownActivityKeys = newKeys;

      ActivityLogState.entries.value = logEntries;
      // Derive weatherCondition from most recent weather activity log entry
      _updateWeatherFromLog(logEntries);
      print('📋 [ACTIVITY LOG] Loaded ${logEntries.length} entries from Firebase');
    });
  }

  /// Update weatherCondition from the most recent weather-type activity log entry.
  void _updateWeatherFromLog(List<ActivityLogEntry> entries) {
    // Find the most recent entry with tag 'weather' (already sorted newest first)
    final weatherEntry = entries.where((e) =>
      e.tag.toLowerCase() == 'weather' ||
      (e.title.contains('Retracted') && e.subtitle1.toLowerCase().contains('rain')) ||
      (e.title.contains('Retracted') && (e.subtitle1.toLowerCase().contains('light') || e.subtitle1.toLowerCase().contains('ldr'))) ||
      (e.title.contains('Extended') && e.tag.toLowerCase() == 'weather')
    ).firstOrNull;

    if (weatherEntry == null) return;

    final title = weatherEntry.title.toLowerCase();
    final subtitle = weatherEntry.subtitle1.toLowerCase();
    final tag = weatherEntry.tag.toLowerCase();

    String newCondition;
    if (title.contains('retracted')) {
      if (subtitle.contains('rain') || tag == 'weather' && subtitle.contains('rain')) {
        newCondition = 'Rain';
      } else if (subtitle.contains('light') || subtitle.contains('ldr') || subtitle.contains('dark') || subtitle.contains('no light')) {
        newCondition = 'No Light';
      } else {
        newCondition = 'Rain'; // default retract = rain
      }
    } else if (title.contains('extended')) {
      if (subtitle.contains('rain stopped') || subtitle.contains('clear')) {
        newCondition = 'Clear';
      } else {
        newCondition = 'Sunny'; // extended = sunlight detected
      }
    } else {
      return;
    }

    print('🌤️ [WEATHER] Derived condition from log: $newCondition (from: ${weatherEntry.title})');
    DryingState.weatherCondition.value = newCondition;
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
    final now = DateTime.now();
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

  /// Create a notification from a new activity log entry.
  /// Only creates notifications for: Retracted Alert, Motion Detected,
  /// Rain Detected, No Light Detected, Security Alert.
  void _createNotificationFromLogEntry(ActivityLogEntry entry) {
    final title = entry.title;
    // Always use the CURRENT active device location & live temperature
    final deviceLocation = deviceList.isNotEmpty
        ? deviceList[activeDeviceIndex].location
        : entry.location;
    final city = deviceLocation.split(',').first.trim();
    final temperature = DryingState.temperature.value.isNotEmpty &&
            DryingState.temperature.value != '--°'
        ? DryingState.temperature.value
        : entry.temp;

    Color sideColor;
    Color titleColor;
    Color iconBg;
    String img;
    String subtitle;
    bool isRain = entry.isRain;

    if (title.contains('Retracted')) {
      // Skip notification for manual retractions
      if (entry.tag.toLowerCase() == 'manual') return;

      sideColor = const Color(0xFF9EA3A7);
      titleColor = const Color(0xFF4A4A4A);
      iconBg = const Color(0xFFE5E5E5);
      img = 'assets/images/masukweathercard.png';
      // Shorten subtitle based on trigger
      if (entry.subtitle1.toLowerCase().contains('rain') || entry.tag.toLowerCase() == 'weather') {
        subtitle = 'Clothesline retracted due to rain';
      } else if (entry.subtitle1.toLowerCase().contains('light') || entry.subtitle1.toLowerCase().contains('ldr')) {
        subtitle = 'Clothesline retracted, no sunlight';
      } else {
        subtitle = entry.subtitle1.isNotEmpty ? entry.subtitle1 : 'Clothesline retracted';
      }
      isRain = true;
    } else if (title.contains('Motion Detected')) {
      sideColor = const Color(0xFFFF4444);
      titleColor = const Color(0xFFFF4444);
      iconBg = const Color(0xFFFFCACA);
      img = 'assets/images/motioncard.png';
      subtitle = 'Motion near the clothesline';
    } else if (title.contains('No Motion')) {
      return;
    } else if (title.contains('Extended')) {
      return;
    } else {
      // Skip other types
      return;
    }

    print('🔔 [NOTIF] Creating notification from log: $title');
    NotificationState.addNotification(
      NotificationEntry(
        title: title,
        subtitle: subtitle,
        temperature: temperature,
        city: city,
        img: img,
        sideColor: sideColor,
        titleColor: titleColor,
        iconBg: iconBg,
        isRain: isRain,
        timestamp: entry.timestamp,
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
