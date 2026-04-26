import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

class MedsafeApp extends StatefulWidget {
  const MedsafeApp({super.key});

  @override
  State<MedsafeApp> createState() => _MedsafeAppState();
}

class _MedsafeAppState extends State<MedsafeApp> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _authController,
      child: Builder(
        builder: (context) {
          final router = createRouter(_authController);
          return MaterialApp.router(
            title: 'Medisafe',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
