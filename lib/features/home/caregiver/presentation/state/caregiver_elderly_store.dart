import 'package:flutter/foundation.dart';

enum CaregiverElderlyStatus { active, inactive }

class CaregiverElderly {
  final String id;
  final String name;
  final int age;
  final String contact;
  final int medicationCount;
  final String lastActivity;
  final String caregiverName;
  final CaregiverElderlyStatus status;

  const CaregiverElderly({
    required this.id,
    required this.name,
    required this.age,
    required this.contact,
    required this.medicationCount,
    required this.lastActivity,
    required this.caregiverName,
    required this.status,
  });

  CaregiverElderly copyWith({
    String? id,
    String? name,
    int? age,
    String? contact,
    int? medicationCount,
    String? lastActivity,
    String? caregiverName,
    CaregiverElderlyStatus? status,
  }) {
    return CaregiverElderly(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      contact: contact ?? this.contact,
      medicationCount: medicationCount ?? this.medicationCount,
      lastActivity: lastActivity ?? this.lastActivity,
      caregiverName: caregiverName ?? this.caregiverName,
      status: status ?? this.status,
    );
  }
}

class CaregiverElderlyStore {
  CaregiverElderlyStore._();

  static final CaregiverElderlyStore instance = CaregiverElderlyStore._();

  final ValueNotifier<List<CaregiverElderly>> elderlies = ValueNotifier(const [
    CaregiverElderly(
      id: 'eld-1',
      name: 'Maria Silva',
      age: 74,
      contact: '(11) 98888-1122',
      medicationCount: 5,
      lastActivity: 'Hoje, 08:02',
      caregiverName: 'Ana Cuidadora',
      status: CaregiverElderlyStatus.active,
    ),
    CaregiverElderly(
      id: 'eld-2',
      name: 'João Pereira',
      age: 80,
      contact: '(11) 97777-2211',
      medicationCount: 4,
      lastActivity: 'Hoje, 12:00',
      caregiverName: 'Ana Cuidadora',
      status: CaregiverElderlyStatus.active,
    ),
    CaregiverElderly(
      id: 'eld-3',
      name: 'Antônio Santos',
      age: 69,
      contact: '(11) 96666-3344',
      medicationCount: 2,
      lastActivity: 'Ontem, 20:00',
      caregiverName: 'Ana Cuidadora',
      status: CaregiverElderlyStatus.active,
    ),
  ]);

  int get activeCount => elderlies.value
      .where((e) => e.status == CaregiverElderlyStatus.active)
      .length;

  void add(CaregiverElderly elderly) {
    elderlies.value = [...elderlies.value, elderly];
  }

  void update(CaregiverElderly elderly) {
    elderlies.value = [
      for (final item in elderlies.value)
        if (item.id == elderly.id) elderly else item,
    ];
  }

  void softDelete(String id) {
    elderlies.value = [
      for (final item in elderlies.value)
        if (item.id == id)
          item.copyWith(status: CaregiverElderlyStatus.inactive)
        else
          item,
    ];
  }

  CaregiverElderly? byId(String id) {
    for (final item in elderlies.value) {
      if (item.id == id) return item;
    }
    return null;
  }
}
