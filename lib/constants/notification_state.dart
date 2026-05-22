import 'package:flutter/foundation.dart';

/// Global notification state shared between Dashboard and NotificationScreen.
/// Uses ValueNotifier so widgets can listen reactively.
class NotificationState {
  /// Whether there are unread notifications (controls the red dot on bell icon).
  static final ValueNotifier<bool> hasUnread = ValueNotifier<bool>(true);

  /// Whether all notifications have been marked as read (persists across screen opens).
  static bool allRead = false;

  /// Mark all notifications as read — persists globally.
  static void markAllAsRead() {
    allRead = true;
    hasUnread.value = false;
  }

  /// Reset state (e.g., when new notification arrives).
  static void setUnread() {
    allRead = false;
    hasUnread.value = true;
  }
}
