import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../widgets/profile_edit_widgets.dart';

class ProfilePhotoPage extends StatefulWidget {
  final String userName;
  const ProfilePhotoPage({super.key, required this.userName});

  @override
  State<ProfilePhotoPage> createState() => _ProfilePhotoPageState();
}

class _ProfilePhotoPageState extends State<ProfilePhotoPage> {
  bool _isLoading = false;
  bool _hasPhoto = false;

  Future<void> _save() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto de perfil atualizada!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  void _pickPhoto(bool fromCamera) {
    setState(() => _hasPhoto = true);
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.userName
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          const ProfileEditHeader(
            title: 'Foto de perfil',
            subtitle: 'Atualize sua foto de perfil',
            icon: Icons.photo_camera_outlined,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              children: [
                // Avatar section
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: AppColors.headerGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(60),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _hasPhoto
                              ? const Icon(Icons.person,
                                  color: Colors.white, size: 52)
                              : Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 42,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -1,
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: GestureDetector(
                          onTap: () => _pickPhoto(true),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFFF5F7FA), width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    _hasPhoto ? 'Foto selecionada' : 'Nenhuma foto adicionada',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const ProfileInfoCard(
                  icon: Icons.photo_size_select_actual_outlined,
                  text:
                      'Escolha uma foto nítida do rosto. Formatos aceitos: JPG e PNG.',
                ),
                const SizedBox(height: 20),
                ProfileFormCard(
                  children: [
                    _PhotoOption(
                      icon: Icons.photo_library_outlined,
                      iconColor: const Color(0xFF8B5CF6),
                      title: 'Escolher da galeria',
                      subtitle: 'Selecione uma foto existente',
                      onTap: () => _pickPhoto(false),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 0),
                    _PhotoOption(
                      icon: Icons.camera_alt_outlined,
                      iconColor: const Color(0xFF0EA5E9),
                      title: 'Tirar foto',
                      subtitle: 'Use a câmera do dispositivo',
                      onTap: () => _pickPhoto(true),
                    ),
                    if (_hasPhoto) ...[
                      const Divider(height: 1, indent: 56, endIndent: 0),
                      _PhotoOption(
                        icon: Icons.delete_outline_rounded,
                        iconColor: AppColors.error,
                        title: 'Remover foto',
                        subtitle: 'Voltar ao avatar com iniciais',
                        onTap: () => setState(() => _hasPhoto = false),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                ProfileSaveButton(
                  label: 'Salvar alterações',
                  enabled: _hasPhoto,
                  isLoading: _isLoading,
                  onPressed: _save,
                ),
                const SizedBox(height: 10),
                ProfileCancelButton(
                    onPressed: () => Navigator.of(context).pop()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PhotoOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(22),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: iconColor == AppColors.error
                          ? AppColors.error
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}
