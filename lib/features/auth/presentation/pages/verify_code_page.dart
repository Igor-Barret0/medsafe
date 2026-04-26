import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/constants/app_colors.dart';
import 'new_password_page.dart';
import 'widgets/auth_header.dart';

class VerifyCodePage extends StatefulWidget {
  const VerifyCodePage({super.key});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  String get _fullCode => _controllers.map((c) => c.text).join();

  Future<void> _confirm() async {
    if (_fullCode.length < 6) {
      setState(() => _error = 'Digite os 6 dígitos do código.');
      return;
    }
    if (_fullCode != '123456') {
      setState(() => _error = 'Código incorreto. Use 123456 para simular.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewPasswordPage()),
    );
    setState(() => _isLoading = false);
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          AuthHeader(
            title: 'Código enviado',
            subtitle: 'Verifique seu e-mail e insira o código de 6 dígitos.',
            showBackButton: true,
            customIcon: const Icon(
              Icons.mark_email_read_outlined,
              size: 34,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AuthCard(
                    children: [
                      const Text(
                        'CÓDIGO DE VERIFICAÇÃO',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          6,
                          (i) => _DigitBox(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            hasError: _error != null,
                            onChanged: (v) => _onDigitChanged(i, v),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.error_outline,
                                size: 14, color: AppColors.error),
                            const SizedBox(width: 6),
                            Text(
                              _error!,
                              style: const TextStyle(
                                  color: AppColors.error, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Reenviar código'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _GradientButton(
                    label: 'Confirmar código',
                    icon: Icons.check_rounded,
                    isLoading: _isLoading,
                    onTap: _confirm,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DigitBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;

  const _DigitBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 58,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: hasError
              ? AppColors.error.withAlpha(10)
              : Colors.grey.withAlpha(13),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasError ? AppColors.error : AppColors.inputBorder,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasError ? AppColors.error : AppColors.inputBorder,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _AuthCard extends StatelessWidget {
  final List<Widget> children;
  const _AuthCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(7),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(70),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
