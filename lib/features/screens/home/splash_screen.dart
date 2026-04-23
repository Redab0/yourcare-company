import 'package:cleaning_service_driver/core/storage/secure_storage_service.dart';
import 'package:cleaning_service_driver/core/themes/app_theme.dart';
import 'package:cleaning_service_driver/core/utils/app_remote_config.dart';
import 'package:cleaning_service_driver/core/utils/app_update_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final AppUpdateService _updateService =
      AppUpdateService(AppRemoteConfig.instance);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final shouldBlockForUpdate = await _updateService.checkForUpdate(context);
    if (shouldBlockForUpdate) {
      return;
    }

    final storage = SecureStorageService();
    final token = await storage.getAccessToken();
    _navigateBasedOnAuthState(token != null);
  }

  void _navigateBasedOnAuthState(bool authenticated) {
    if (!mounted) return;
    authenticated ? context.go('/home') : context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).primaryColor, AppTheme.olive],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.asset(
                    width: 100,
                    height: 100,
                    'assets/images/ic_yourcare.png',
                    color: AppTheme.cream,
                  ),
                ),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.asset(
                    width: 200,
                    height: 200,
                    'assets/images/ic_text_logo.png',
                    color: AppTheme.cream,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 45,
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.translate(
                offset: const Offset(0, -50), // pull up ~8px
                child: Text(
                  "Partner",
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(color: AppTheme.cream),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
