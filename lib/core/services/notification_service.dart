import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/home/user/domain/medication.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _medChannelId = 'medication_reminder';
  static const String _medChannelName = 'Lembretes de Medicamento';
  static const String _medChannelDesc =
      'Lembretes para tomar seus medicamentos no horário certo';
  static const String _caregiverChannelId = 'caregiver_alert';
  static const String _caregiverChannelName = 'Alertas ao Cuidador';
  static const String _caregiverChannelDesc =
      'Alertas quando o idoso não tomou o medicamento após todas as tentativas';

  // ── Initialization ──────────────────────────────────────────────────────────

  Future<void> initialize() async {
    tz.initializeTimeZones();
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(initSettings);

    // Request permissions on Android 13+
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Cancels any existing notifications for [med] and schedules fresh ones
  /// based on the medication's time, frequency, alertInterval and maxAttempts.
  /// If a caregiverPhone is set, an escalation alert fires after all attempts.
  Future<void> scheduleMedicationReminder(Medication med) async {
    await cancelMedicationNotifications(med.id);

    final baseId = _baseId(med.id);
    final maxCount = _maxAttemptsCount(med.maxAttempts);
    final intervalMins = _intervalMinutes(med.alertInterval);
    final repeatComponent = _repeatComponent(med.frequency);

    for (int i = 0; i < maxCount; i++) {
      await _scheduleAttempt(
        id: baseId + i,
        med: med,
        attempt: i + 1,
        maxAttempts: maxCount,
        delayMinutes: i * intervalMins,
        repeatComponent: repeatComponent,
      );
    }

    // Caregiver escalation after all attempts
    if (med.caregiverPhone != null && med.caregiverPhone!.isNotEmpty) {
      await _scheduleCaregiverAlert(
        id: baseId + 10,
        med: med,
        delayMinutes: maxCount * intervalMins,
      );
    }
  }

  /// Cancels all notifications (attempts + caregiver) for a given medication.
  Future<void> cancelMedicationNotifications(String medId) async {
    final base = _baseId(medId);
    for (int i = 0; i <= 11; i++) {
      await _plugin.cancel(base + i);
    }
  }

  // ── Scheduling helpers ──────────────────────────────────────────────────────

  Future<void> _scheduleAttempt({
    required int id,
    required Medication med,
    required int attempt,
    required int maxAttempts,
    required int delayMinutes,
    required DateTimeComponents? repeatComponent,
  }) async {
    final scheduledTime = _nextOccurrence(med.time, delayMinutes);

    final androidDetails = AndroidNotificationDetails(
      _medChannelId,
      _medChannelName,
      channelDescription: _medChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      color: const Color(0xFF3B82F6),
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    final body = attempt == 1
        ? '${med.dose} · Horário: ${med.formattedTime}'
        : 'Tentativa $attempt de $maxAttempts · ${med.dose}';

    await _plugin.zonedSchedule(
      id,
      '💊 ${med.name}',
      body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: repeatComponent,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _scheduleCaregiverAlert({
    required int id,
    required Medication med,
    required int delayMinutes,
  }) async {
    final scheduledTime = _nextOccurrence(med.time, delayMinutes);

    final androidDetails = AndroidNotificationDetails(
      _caregiverChannelId,
      _caregiverChannelName,
      channelDescription: _caregiverChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      color: const Color(0xFFEF4444),
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    final caregiverName = med.caregiverName ?? 'Cuidador';
    final maxCount = _maxAttemptsCount(med.maxAttempts);

    await _plugin.zonedSchedule(
      id,
      '⚠️ Atenção, $caregiverName!',
      '${med.name} não foi tomado após $maxCount tentativas.',
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Time helpers ────────────────────────────────────────────────────────────

  tz.TZDateTime _nextOccurrence(TimeOfDay time, int delayMinutes) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    ).add(Duration(minutes: delayMinutes));

    // If the time already passed today, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ── Enum converters ─────────────────────────────────────────────────────────

  /// Maps MedicationFrequency to the DateTimeComponents for repeating schedules.
  /// Returns null for non-standard frequencies (quinzenal, mensal) — one-time only.
  DateTimeComponents? _repeatComponent(MedicationFrequency freq) {
    switch (freq) {
      case MedicationFrequency.diario:
      case MedicationFrequency.duasVezesDia:
      case MedicationFrequency.tresVezesDia:
        return DateTimeComponents.time;
      case MedicationFrequency.semanalDom:
      case MedicationFrequency.semanalSeg:
      case MedicationFrequency.semanalTer:
      case MedicationFrequency.semanalQua:
      case MedicationFrequency.semanalQui:
      case MedicationFrequency.semanalSex:
      case MedicationFrequency.semanalSab:
        return DateTimeComponents.dayOfWeekAndTime;
      case MedicationFrequency.quinzenal:
      case MedicationFrequency.mensal:
        return null;
    }
  }

  int _maxAttemptsCount(MaxAttempts m) {
    switch (m) {
      case MaxAttempts.uma:
        return 1;
      case MaxAttempts.duas:
        return 2;
      case MaxAttempts.tres:
        return 3;
      case MaxAttempts.quatro:
        return 4;
      case MaxAttempts.cinco:
        return 5;
    }
  }

  int _intervalMinutes(AlertInterval a) {
    switch (a) {
      case AlertInterval.cincoMin:
        return 5;
      case AlertInterval.dezMin:
        return 10;
      case AlertInterval.quinzeMin:
        return 15;
      case AlertInterval.trintaMin:
        return 30;
      case AlertInterval.umaHora:
        return 60;
    }
  }

  // Unique base ID per medication (5 slots for attempts + 1 for caregiver = 11 total)
  int _baseId(String medId) => medId.hashCode.abs() % 90000;
}
