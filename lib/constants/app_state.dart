// Global app state — shared mutable data across screens.
// Using simple top-level variables (no provider/riverpod needed for this scope).
import 'package:flutter/foundation.dart';

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
