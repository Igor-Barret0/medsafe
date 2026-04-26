import 'package:flutter/material.dart';

enum MedicationStatus { tomado, atrasado, pendente }

enum MedicationFrequency {
  diario,
  duasVezesDia,
  tresVezesDia,
  semanalDom,
  semanalSeg,
  semanalTer,
  semanalQua,
  semanalQui,
  semanalSex,
  semanalSab,
  quinzenal,
  mensal;

  String get label => switch (this) {
        MedicationFrequency.diario => 'Diário',
        MedicationFrequency.duasVezesDia => '2x ao dia',
        MedicationFrequency.tresVezesDia => '3x ao dia',
        MedicationFrequency.semanalDom => 'Semanal (Dom)',
        MedicationFrequency.semanalSeg => 'Semanal (Seg)',
        MedicationFrequency.semanalTer => 'Semanal (Ter)',
        MedicationFrequency.semanalQua => 'Semanal (Qua)',
        MedicationFrequency.semanalQui => 'Semanal (Qui)',
        MedicationFrequency.semanalSex => 'Semanal (Sex)',
        MedicationFrequency.semanalSab => 'Semanal (Sáb)',
        MedicationFrequency.quinzenal => 'Quinzenal',
        MedicationFrequency.mensal => 'Mensal',
      };
}

enum AlertInterval {
  cincoMin,
  dezMin,
  quinzeMin,
  trintaMin,
  umaHora;

  String get label => switch (this) {
        AlertInterval.cincoMin => '5 minutos',
        AlertInterval.dezMin => '10 minutos',
        AlertInterval.quinzeMin => '15 minutos',
        AlertInterval.trintaMin => '30 minutos',
        AlertInterval.umaHora => '1 hora',
      };
}

enum MaxAttempts {
  uma,
  duas,
  tres,
  quatro,
  cinco;

  String get label => switch (this) {
        MaxAttempts.uma => '1 tentativa',
        MaxAttempts.duas => '2 tentativas',
        MaxAttempts.tres => '3 tentativas',
        MaxAttempts.quatro => '4 tentativas',
        MaxAttempts.cinco => '5 tentativas',
      };
}

class Medication {
  final String id;
  final String name;
  final String dose;
  final TimeOfDay time;
  final MedicationStatus status;
  final MedicationFrequency frequency;
  final AlertInterval alertInterval;
  final MaxAttempts maxAttempts;
  final String? caregiverName;
  final String? caregiverPhone;
  final int? stockRemaining;

  const Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.time,
    required this.status,
    this.frequency = MedicationFrequency.diario,
    this.alertInterval = AlertInterval.cincoMin,
    this.maxAttempts = MaxAttempts.tres,
    this.caregiverName,
    this.caregiverPhone,
    this.stockRemaining,
  });

  String get formattedTime =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
