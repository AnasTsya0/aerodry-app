import 'dart:ui';
import 'package:flutter/foundation.dart';

/// Model for a single notification entry.
class NotificationEntry {
  final String title;
  final String subtitle;
  final String temperature;
  final String city;
  final String img;
  final Color sideColor;
  final Color titleColor;
  final Color iconBg;
  final bool isRain;
  final DateTime timestamp;
  bool isRead;

  NotificationEntry({
    required this.title,
    required this.subtitle,
    required this.temperature,
    required this.city,
    required this.img,
    required this.sideColor,
    required this.titleColor,
    required this.iconBg,
    this.isRain = false,
    required this.timestamp,
    this.isRead = false,
  });

  /// Format time as relative "Just now", "X min ago", etc.
  String get formattedTime {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final diff = now.difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hour ago';
    return '${diff.inDays} days ago';
  }
}

/// Global notification state shared between Dashboard and NotificationScreen.
/// Uses ValueNotifier so widgets can listen reactively.
class NotificationState {
  /// Whether there are unread notifications (controls the red dot on bell icon).
  static final ValueNotifier<bool> hasUnread = ValueNotifier<bool>(false);

  /// Whether all notifications have been marked as read (persists across screen opens).
  static bool allRead = true;

  /// List of notification entries — updated in real-time by FirebaseService.
  static final ValueNotifier<List<NotificationEntry>> entries =
      ValueNotifier<List<NotificationEntry>>([]);

  /// Mark all notifications as read — persists globally.
  static void markAllAsRead() {
    allRead = true;
    hasUnread.value = false;
    final updated = entries.value.map((e) {
      e.isRead = true;
      return e;
    }).toList();
    entries.value = updated;
  }

  /// Add a new notification and set unread.
  static void addNotification(NotificationEntry entry) {
    allRead = false;
    hasUnread.value = true;
    final updated = List<NotificationEntry>.from(entries.value);
    updated.insert(0, entry);
    entries.value = updated;
  }

  /// Reset state (e.g., when new notification arrives).
  static void setUnread() {
    allRead = false;
    hasUnread.value = true;
  }
}
