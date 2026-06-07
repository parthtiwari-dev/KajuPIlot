import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/today/data/today_models.dart';

final kajuNotificationServiceProvider = Provider<KajuNotificationService>(
  (ref) => KajuNotificationService(),
);

class KajuNotificationService {
  KajuNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  var _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    _initialized = true;
  }

  Future<void> reschedule({
    required List<TaskListItem> tasks,
    TodayInsights? insights,
    DateTime? now,
  }) async {
    await initialize();
    await _plugin.cancelAll();

    final current = now ?? DateTime.now();
    final pendingTasks = tasks.where((item) {
      return item.status != TaskStatusValue.done &&
          item.task.deletedAt == null &&
          item.task.scheduledAt.isAfter(current);
    }).toList();

    for (final item in pendingTasks) {
      await _scheduleNotification(
        id: _taskNotificationId(item.task.id),
        title: 'KajuPilot: ${item.type.label}',
        body: item.party == null
            ? item.task.title
            : '${item.party!.name}: ${item.task.title}',
        scheduledAt:
            tz.TZDateTime.from(item.task.scheduledAt.toLocal(), tz.local),
        details: const NotificationDetails(
          android: AndroidNotificationDetails(
            'kajupilot_tasks',
            'Task reminders',
            channelDescription: 'Reminders for calls, payments, and deliveries',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        preferExact: true,
      );
    }

    final todayInsights = insights;
    if (todayInsights != null) {
      await _scheduleMorningSummary(todayInsights, current);
      await _scheduleHourlyNudge(todayInsights, current);
    }
  }

  Future<void> _scheduleMorningSummary(
    TodayInsights insights,
    DateTime now,
  ) async {
    var target = DateTime(now.year, now.month, now.day, 8);
    if (!target.isAfter(now)) {
      target = target.add(const Duration(days: 1));
    }

    await _scheduleNotification(
      id: 80001,
      title: 'KajuPilot morning plan',
      body:
          '${insights.callsDue} calls today, ${_formatCompactRupees(insights.pendingCollectionPaise)} to collect',
      scheduledAt: tz.TZDateTime.from(target, tz.local),
      details: const NotificationDetails(
        android: AndroidNotificationDetails(
          'kajupilot_summary',
          'Morning summary',
          channelDescription: 'Daily KajuPilot morning summary',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      preferExact: false,
    );
  }

  Future<void> _scheduleHourlyNudge(
    TodayInsights insights,
    DateTime now,
  ) async {
    final pendingCount = insights.callsDue + insights.deliveriesDue;
    if (pendingCount == 0 || now.hour >= 18) {
      return;
    }

    final startHour = max(now.hour + 1, 10);
    const endHour = 18;

    for (var hour = startHour; hour <= endHour; hour++) {
      final target = DateTime(now.year, now.month, now.day, hour);
      if (!target.isAfter(now)) {
        continue;
      }

      await _scheduleNotification(
        id: 80002 + hour,
        title: 'KajuPilot nudge',
        body: '$pendingCount pending items still need attention today',
        scheduledAt: tz.TZDateTime.from(target, tz.local),
        details: const NotificationDetails(
          android: AndroidNotificationDetails(
            'kajupilot_nudges',
            'Workday nudges',
            channelDescription: 'Quiet nudges while work remains pending',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        preferExact: false,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledAt,
    required NotificationDetails details,
    required bool preferExact,
  }) async {
    final mode = preferExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledAt,
        details,
        androidScheduleMode: mode,
      );
    } on PlatformException catch (error) {
      if (preferExact && error.code == 'exact_alarms_not_permitted') {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          scheduledAt,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
        return;
      }
      rethrow;
    }
  }

  int _taskNotificationId(String id) {
    return id.codeUnits.fold(17, (value, unit) => value * 37 + unit) &
        0x7fffffff;
  }

  String _formatCompactRupees(int paise) {
    final rupees = paise / 100;
    if (rupees >= 100000) {
      return '₹${(rupees / 100000).toStringAsFixed(1)}L';
    }
    if (rupees >= 1000) {
      return '₹${(rupees / 1000).toStringAsFixed(0)}K';
    }
    return '₹${rupees.toStringAsFixed(0)}';
  }
}
