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

