import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_colors.dart';

class CaregiverAlertPage extends StatelessWidget {
  final String patientName;
  final String medicationName;
  final String scheduledTime;
  final int attempts;
  final int maxAttempts;
  final String lastAlertTime;
  final String caregiverName;
  final String caregiverPhone;

  const CaregiverAlertPage({
    super.key,
    this.patientName = 'Igor Silva',
    this.medicationName = 'Metformina 500mg',
    this.scheduledTime = '12:00',
    this.attempts = 3,
    this.maxAttempts = 3,
    this.lastAlertTime = '12:15',
    this.caregiverName = 'Maria Silva',
    this.caregiverPhone = '(11) 98888-7777',
  });

  String get _patientInitial => patientName.isNotEmpty
      ? patientName.trim()[0].toUpperCase()
      : '?';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
                _buildPatientCard(),
                const SizedBox(height: 12),
                _buildDetailsCard(),
                const SizedBox(height: 12),
                _buildCaregiverNotified(),
                const SizedBox(height: 24),
                _buildOkButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 34,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Alerta ao Cuidador',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Notificação enviada automaticamente',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEEDE3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _patientInitial,
                    style: const TextStyle(
                      color: Color(0xFFF97316),
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Paciente',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    patientName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '"${patientName.split(' ').first} não confirmou a medicação no horário previsto."',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFEA580C),
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DETALHES DO MEDICAMENTO',
            style: TextStyle(
              color: Color(0xFFF97316),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.medication_rounded,
            iconColor: AppColors.error,
            label: 'Medicamento',
            value: medicationName,
          ),
          const Divider(height: 18),
          _DetailRow(
            icon: Icons.schedule_rounded,
            iconColor: AppColors.textSecondary,
            label: 'Horário previsto',
            value: scheduledTime,
          ),
          const Divider(height: 18),
          _DetailRow(
            icon: Icons.refresh_rounded,
            iconColor: AppColors.primary,
            label: 'Tentativas realizadas',
            value: '$attempts de $maxAttempts (máximo atingido)',
          ),
          const Divider(height: 18),
          _DetailRow(
            icon: Icons.notifications_rounded,
            iconColor: AppColors.warning,
            label: 'Último alerta em',
            value: lastAlertTime,
          ),
        ],
      ),
    );
  }

  Widget _buildCaregiverNotified() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cuidador notificado',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '$caregiverName — $caregiverPhone',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOkButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF97316),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'OK, entendi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
