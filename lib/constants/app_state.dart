// Global app state — shared mutable data across screens.
// Using simple top-level variables (no provider/riverpod needed for this scope).
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Device model ─────────────────────────────────────────────────────────────

class DeviceModel {
  final String name;
  final String location;

  const DeviceModel({required this.name, required this.location});
}

// ─── Device list ──────────────────────────────────────────────────────────────

/// All registered devices. Pre-seeded with 2 defaults.
List<DeviceModel> deviceList = [
  DeviceModel(name: 'House, Aero Dry', location: 'Tangerang, House'),
  DeviceModel(
    name: 'Boarding House, Aero Dry',
    location: 'Jakarta, Boarding House',
  ),
];

/// Index of the currently active/online device.
int activeDeviceIndex = 0;

// ─── Search history ───────────────────────────────────────────────────────────

/// Persists across SearchLocationScreen opens — grows when user clicks a result.
List<String> searchHistory = [];

void addToSearchHistory(String location) {
  if (!searchHistory.contains(location)) {
    searchHistory.insert(0, location);
  }
}

// ─── Rack state (shared between Dashboard ↔ Manual) ─────────────────────────

class RackState {
  RackState._();

  /// 'Extended' or 'Retracted' — updated from Firebase status/rackPosition
  static final ValueNotifier<String> rackStatus = ValueNotifier('Retracted');

  /// Time of last Move In / Move Out action (null = never)
  static final ValueNotifier<DateTime?> lastActionTime = ValueNotifier(null);

  /// Update from Firebase — called by FirebaseService
  static void updateFromFirebase(String rackPosition) {
    final newStatus = rackPosition == 'OUT' ? 'Extended' : 'Retracted';
    if (rackStatus.value != newStatus) {
      rackStatus.value = newStatus;
      lastActionTime.value = DateTime.now().toUtc().add(
        const Duration(hours: 7),
      );
    }
  }

  static void moveOut() {
    rackStatus.value = 'Extended';
    lastActionTime.value = DateTime.now().toUtc().add(const Duration(hours: 7));
  }

  static void moveIn() {
    rackStatus.value = 'Retracted';
    lastActionTime.value = DateTime.now().toUtc().add(const Duration(hours: 7));
  }
}

// ─── Drying state (shared across Dashboard, Manual, ManualDetail) ────────────

class DryingState {
  DryingState._();

  /// Timer for counting drying duration locally
  static Timer? _dryingTimer;

  /// Whether drying duration is frozen (rack came back IN)
  static bool _isDurationFrozen = false;

  static String? lastManualDirection;
  
  /// 'Automatic' or 'Manual' — from Firebase status/mode
  static final ValueNotifier<String> mode = ValueNotifier('Automatic');

  /// UI-only display mode: shows 'Manual' after manual control,
  /// reverts to 'Automatic' when sensor triggers or Firebase reports AUTO.
  /// This does NOT affect the actual ESP mode — ESP always stays AUTO.
  static final ValueNotifier<String> displayMode = ValueNotifier('Automatic');

  /// Tracks the reason WHY the last action happened.
  /// Used by activity log to show specific sensor/trigger info.
  static final ValueNotifier<String> lastTriggerReason = ValueNotifier('');

  /// Tracks WHICH SENSOR triggered the last automatic action.
  /// Used by activity log to set the correct tag.
  /// Values: 'Manual', 'Rain Sensor', 'Weather Forecast', etc.
  static final ValueNotifier<String> lastTriggerSensor = ValueNotifier(
    'Manual',
  );

  /// Last update time shown on drying card (null = never updated)
  static final ValueNotifier<DateTime?> lastUpdateTime = ValueNotifier(null);

  /// Current weather condition label (e.g. 'Clear Sky', 'Rain', etc.)
  static final ValueNotifier<String> weatherCondition = ValueNotifier(
    'Clear Sky',
  );

  /// Current device location displayed on drying card
  static final ValueNotifier<String> location = ValueNotifier('--');

  /// Current temperature displayed on drying card
  static final ValueNotifier<String> temperature = ValueNotifier('--°');

  /// When drying started (move-out time). null = not currently drying.
  static final ValueNotifier<DateTime?> dryingStartTime = ValueNotifier(null);

  // ─── Firebase-synced values ───────────────────────────────────────────

  /// Drying duration in minutes from Firebase status/dryingDuration
  static final ValueNotifier<int> dryingDurationMinutes = ValueNotifier(0);

  /// Motor status from Firebase: "STOP", "MOVING_OUT", "MOVING_IN"
  static final ValueNotifier<String> motorStatus = ValueNotifier('STOP');

  /// Progress 0–100 from Firebase status/progress
  static final ValueNotifier<int> progress = ValueNotifier(0);

  /// Rack position from Firebase: "IN" or "OUT"
  static final ValueNotifier<String> rackPosition = ValueNotifier('IN');

  /// Online status from Firebase status/online
  static final ValueNotifier<bool> online = ValueNotifier(false);

  /// Obstacle detected from Firebase status/obstacle
  static final ValueNotifier<bool> obstacle = ValueNotifier(false);

  /// Format the lastUpdateTime as "H : mm"
  static String get formattedLastUpdate {
    final t = lastUpdateTime.value;
    if (t == null) return '9 : 15';
    final h = t.hour;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h : $m';
  }

  /// Compute drying duration display string
  static String get formattedDryingDuration {
    // If rack is OUT and we're tracking locally, show elapsed time
    if (dryingStartTime.value != null) {
      final now = DateTime.now().toUtc().add(const Duration(hours: 7));
      final elapsed = now.difference(dryingStartTime.value!).inMinutes;
      if (elapsed <= 0) return '0 Minutes';
      if (elapsed == 1) return '1 Minute';
      return '$elapsed Minutes';
    }
    // Otherwise use Firebase value
    final mins = dryingDurationMinutes.value;
    if (mins <= 0) return '-- Minutes';
    if (mins == 1) return '1 Minute';
    return '$mins Minutes';
  }

  /// Called when manual control process succeeds
  static void onManualSuccess({
    required String moveType,
    required String weatherLabel,
    required String deviceLocation,
    required String deviceTemperature,
  }) {
    // Only update the UI display mode — ESP stays AUTO
    displayMode.value = 'Manual';
    lastTriggerSensor.value = 'Manual';
    lastTriggerReason.value = moveType == 'out'
        ? 'Manual move out by user'
        : 'Manual move in by user';
    lastUpdateTime.value = DateTime.now().toUtc().add(const Duration(hours: 7));
    weatherCondition.value = weatherLabel;
    location.value = deviceLocation;
    temperature.value = deviceTemperature;

    final now = DateTime.now().toUtc().add(const Duration(hours: 7));

    if (moveType == 'out') {
      dryingStartTime.value = now;
    } else {
      dryingStartTime.value = null;
    }
  }

  /// Called when a sensor triggers an automatic action (rain, etc.)
  /// This reverts the UI display back to 'Automatic' and records the reason.
  /// [sensorName] identifies which sensor triggered (e.g. 'Rain Sensor', 'Weather Forecast')
  static void onSensorTriggered(String reason, {String sensorName = 'Sensor'}) {
    displayMode.value = 'Automatic';
    lastTriggerReason.value = reason;
    lastTriggerSensor.value = sensorName;
  }

  /// Update all drying state fields from Firebase snapshot
  static void updateFromFirebase({
    required String fbMode,
    required int fbDryingDuration,
    required String fbMotorStatus,
    required int fbProgress,
    required String fbRackPosition,
    required bool fbOnline,
    required bool fbObstacle,
    required int fbLastUpdate,
  }) {
    // Map Firebase mode to display
    mode.value = fbMode == 'AUTO' ? 'Automatic' : 'Manual';
    // If Firebase reports AUTO mode, revert displayMode to Automatic
    // (sensor triggered an action, so UI should show Automatic)
    if (fbMode == 'AUTO') {
      displayMode.value = 'Automatic';
    }
    motorStatus.value = fbMotorStatus;

    // Abaikan progress lama kalau motor belum bergerak
    if (fbMotorStatus == 'MOVING_OUT' || fbMotorStatus == 'MOVING_IN') {
      progress.value = fbProgress;
    }
    online.value = fbOnline;
    obstacle.value = fbObstacle;

    // Track rack transitions BEFORE updating rackPosition
    final prevRack = rackPosition.value;
    rackPosition.value = fbRackPosition;

    // Rack went OUT — start local drying timer from 0
    if (fbRackPosition == 'OUT' && prevRack != 'OUT') {
      _isDurationFrozen = false;
      dryingStartTime.value = DateTime.now().toUtc().add(
        const Duration(hours: 7),
      );
      dryingDurationMinutes.value = 0;
      _startDryingCountTimer();
    }
    // Rack came IN — freeze duration at last counted value
    else if (fbRackPosition == 'IN' && prevRack != 'IN') {
      _stopDryingCountTimer();
      // Compute final elapsed and freeze it
      if (dryingStartTime.value != null) {
        final now = DateTime.now().toUtc().add(const Duration(hours: 7));
        final elapsed = now.difference(dryingStartTime.value!).inMinutes;
        dryingDurationMinutes.value = elapsed;
      }
      dryingStartTime.value = null;
      _isDurationFrozen = true;
    }
    // No transition — use Firebase value only if NOT frozen and NOT tracking locally
    else if (dryingStartTime.value == null && !_isDurationFrozen) {
      dryingDurationMinutes.value = fbDryingDuration;
    }

    // Convert epoch seconds to DateTime for lastUpdate
    if (fbLastUpdate > 0) {
      lastUpdateTime.value = DateTime.fromMillisecondsSinceEpoch(
        fbLastUpdate * 1000,
        isUtc: true,
      ).add(const Duration(hours: 7));
    }
  }

  /// Reset everything (e.g. when a full new drying session starts from scratch)
  static void resetDryingSession() {
    _stopDryingCountTimer();
    dryingStartTime.value = null;
  }

  /// Start local timer that counts drying minutes from dryingStartTime
  static void _startDryingCountTimer() {
    _dryingTimer?.cancel();
    dryingDurationMinutes.value = 0;
    _dryingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (dryingStartTime.value != null) {
        final now = DateTime.now().toUtc().add(const Duration(hours: 7));
        final elapsed = now.difference(dryingStartTime.value!).inMinutes;
        dryingDurationMinutes.value = elapsed;
      }
    });
  }

  /// Stop the local drying timer
  static void _stopDryingCountTimer() {
    _dryingTimer?.cancel();
    _dryingTimer = null;
  }
}

// ─── Security state ───────────────────────────────────────────────────────────

class SecurityState {
  SecurityState._();

  /// Whether security mode is enabled — from Firebase control/securityMode
  static final ValueNotifier<bool> securityMode = ValueNotifier(true);

  /// Whether alarm is currently triggered — from Firebase control/alarmTriggered
  static final ValueNotifier<bool> alarmTriggered = ValueNotifier(false);

  /// IR sensor value — from Firebase sensor/ir (0 = motion detected)
  static final ValueNotifier<int> irSensor = ValueNotifier(0);

  /// Update from Firebase
  static void updateFromFirebase({
    required bool fbSecurityMode,
    required bool fbAlarmTriggered,
  }) {
    securityMode.value = fbSecurityMode;
    alarmTriggered.value = fbAlarmTriggered;
  }
}

// ─── Activity Log entry model ─────────────────────────────────────────────────

enum ActivityType { motion, weather, manual }

class ActivityLogEntry {
  final String title;
  final String subtitle1;
  final String subtitle2;
  final String tag; // 'Motion' | 'Weather' | 'Manual'
  final ActivityType type;
  final DateTime timestamp;
  final String imagePath; // asset image used as icon
  final String temp;
  final bool isRain;
  final String location; // device location

  ActivityLogEntry({
    required this.title,
    required this.subtitle1,
    this.subtitle2 = '',
    required this.tag,
    required this.type,
    required this.timestamp,
    required this.imagePath,
    this.temp = '28°',
    this.isRain = false,
    this.location = 'Jakarta',
  });

  String get formattedTime {
    final d = DateFormat('EEE, MMM dd').format(timestamp);
    final t = DateFormat('h : mm a').format(timestamp);
    return '$d\n$t';
  }
}

// ─── Activity Log state ───────────────────────────────────────────────────────

class ActivityLogState {
  ActivityLogState._();

  static final ValueNotifier<List<ActivityLogEntry>> entries =
      ValueNotifier<List<ActivityLogEntry>>([]);

  /// Add a manual control entry to the top of the list
  static void addManualEntry({
    required String moveType,
    required String weatherLabel,
  }) {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final isOut = moveType == 'out';
    // Use the active device's location
    final location = deviceList.isNotEmpty
        ? deviceList[activeDeviceIndex].location
        : 'Jakarta';
    final newEntry = ActivityLogEntry(
      title: isOut ? 'Extended Alert' : 'Retracted Alert',
      subtitle1: isOut ? 'Manual Move Out' : 'Manual Move In',
      subtitle2: 'Confirmed',
      tag: 'Manual',
      type: ActivityType.manual,
      timestamp: now,
      imagePath: isOut
          ? 'assets/images/moveoutmanual.png'
          : 'assets/images/moveinmanual.png',
      temp: '28°',
      location: location,
    );
    final updated = List<ActivityLogEntry>.from(entries.value);
    updated.insert(0, newEntry);
    entries.value = updated;
  }

  /// Add an entry from Firebase event (motion, weather, rack change)
  static void addFirebaseEntry({
    required String title,
    required String subtitle1,
    String subtitle2 = '',
    required String tag,
    required ActivityType type,
    required String imagePath,
    String temp = '28°',
    bool isRain = false,
  }) {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final location = deviceList.isNotEmpty
        ? deviceList[activeDeviceIndex].location
        : 'Jakarta';
    final newEntry = ActivityLogEntry(
      title: title,
      subtitle1: subtitle1,
      subtitle2: subtitle2,
      tag: tag,
      type: type,
      timestamp: now,
      imagePath: imagePath,
      temp: temp,
      isRain: isRain,
      location: location,
    );
    final updated = List<ActivityLogEntry>.from(entries.value);
    updated.insert(0, newEntry);
    entries.value = updated;
  }
}

// ─── User Profile state (loaded from signup/login, displayed in Profile) ──────

class UserProfileState {
  UserProfileState._();

  static final ValueNotifier<String> name = ValueNotifier('Rania');
  static final ValueNotifier<String> email = ValueNotifier(
    'raniamasyaputri@gmail.com',
  );

  static Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('userProfileName');
    final savedEmail = prefs.getString('userProfileEmail');
    if (savedName != null) {
      name.value = savedName;
    }
    if (savedEmail != null) {
      email.value = savedEmail;
    }
  }

  static Future<void> saveToPrefs({
    required String newName,
    required String newEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userProfileName', newName);
    await prefs.setString('userProfileEmail', newEmail);
    name.value = newName;
    email.value = newEmail;
  }
}
