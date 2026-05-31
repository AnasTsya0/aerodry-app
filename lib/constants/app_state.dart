// Global app state — shared mutable data across screens.
// Using simple top-level variables (no provider/riverpod needed for this scope).
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

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
  DeviceModel(name: 'Boarding House, Aero Dry', location: 'Jakarta, Boarding House'),
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

  /// 'Extended' or 'Retracted'
  static final ValueNotifier<String> rackStatus = ValueNotifier('Extended');

  /// Time of last Move In / Move Out action (null = never)
  static final ValueNotifier<DateTime?> lastActionTime = ValueNotifier(null);

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

  /// 'Automatic' or 'Manual'
  static final ValueNotifier<String> mode = ValueNotifier('Automatic');

  /// Last update time shown on drying card (null = never updated)
  static final ValueNotifier<DateTime?> lastUpdateTime = ValueNotifier(null);

  /// Current weather condition label (e.g. 'Clear Sky', 'Rain', etc.)
  static final ValueNotifier<String> weatherCondition = ValueNotifier('Clear Sky');

  /// Format the lastUpdateTime as "H : mm"
  static String get formattedLastUpdate {
    final t = lastUpdateTime.value;
    if (t == null) return '9 : 15';
    final h = t.hour;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h : $m';
  }

  /// Called when manual control process succeeds
  static void onManualSuccess({required String weatherLabel}) {
    mode.value = 'Manual';
    lastUpdateTime.value = DateTime.now().toUtc().add(const Duration(hours: 7));
    weatherCondition.value = weatherLabel;
  }
}

// ─── Activity Log entry model ─────────────────────────────────────────────────

enum ActivityType { motion, weather, manual }

class ActivityLogEntry {
  final String title;
  final String subtitle1;
  final String subtitle2;
  final String tag;          // 'Motion' | 'Weather' | 'Manual'
  final ActivityType type;
  final DateTime timestamp;
  final String imagePath;    // asset image used as icon
  final String temp;
  final bool isRain;

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
      ValueNotifier<List<ActivityLogEntry>>(_defaultEntries());

  static List<ActivityLogEntry> _defaultEntries() {
    final base = DateTime(2024, 4, 1);
    return [
      ActivityLogEntry(
        title: 'Motion Detected',
        subtitle1: 'Activity Detected In',
        subtitle2: 'The Laundry Area',
        tag: 'Motion',
        type: ActivityType.motion,
        timestamp: base.add(const Duration(hours: 6, minutes: 15)),
        imagePath: 'assets/images/motioncard.png',
        temp: '28°',
      ),
      ActivityLogEntry(
        title: 'Retracted Alert',
        subtitle1: 'Movement Detected',
        subtitle2: 'In The Area',
        tag: 'Motion',
        type: ActivityType.motion,
        timestamp: base.add(const Duration(hours: 6, minutes: 18)),
        imagePath: 'assets/images/moveinmanual.png',
        temp: '28°',
      ),
      ActivityLogEntry(
        title: 'No Motion Detected',
        subtitle1: 'Clothesline Area Is',
        subtitle2: 'Safe',
        tag: 'Motion',
        type: ActivityType.motion,
        timestamp: base.add(const Duration(hours: 7, minutes: 20)),
        imagePath: 'assets/images/nomotioncard.png',
        temp: '29°',
      ),
      ActivityLogEntry(
        title: 'Extended Alert',
        subtitle1: 'Safe Conditions',
        subtitle2: 'Detected',
        tag: 'Motion',
        type: ActivityType.motion,
        timestamp: base.add(const Duration(hours: 7, minutes: 23)),
        imagePath: 'assets/images/moveoutmanual.png',
        temp: '29°',
      ),
      ActivityLogEntry(
        title: 'Retracted Alert',
        subtitle1: 'Rain Detected',
        tag: 'Weather',
        type: ActivityType.weather,
        timestamp: base.add(const Duration(hours: 8, minutes: 20)),
        imagePath: 'assets/images/moveinmanual.png',
        temp: '28°',
        isRain: true,
      ),
      ActivityLogEntry(
        title: 'Extended Alert',
        subtitle1: 'Heat Warning Retracted',
        tag: 'Weather',
        type: ActivityType.weather,
        timestamp: base.add(const Duration(hours: 9, minutes: 15)),
        imagePath: 'assets/images/moveoutmanual.png',
        temp: '31°',
      ),
    ];
  }

  /// Add a manual control entry to the top of the list
  static void addManualEntry({required String moveType, required String weatherLabel}) {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final isOut = moveType == 'out';
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
    );
    final updated = List<ActivityLogEntry>.from(entries.value);
    updated.insert(0, newEntry);
    entries.value = updated;
  }
}

