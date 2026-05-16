import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/driver_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;
  late Animation<double>   _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale   = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _opacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.5)));
    _ctrl.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1800));
      if (!mounted) return;
      
      final auth = context.read<AuthService>();
      await auth.checkSession().timeout(const Duration(seconds: 10));
      
      if (!mounted) return;
      if (auth.isLoggedIn && auth.dbUserId != null) {
        await context.read<DriverService>().loadDriver(auth.dbUserId!)
            .timeout(const Duration(seconds: 10));
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 120, height: 120,
                  child: Image.asset('assets/images/icon.png', fit: BoxFit.contain),
                ),
                const SizedBox(height: 20),
                const Text('AmbuLink',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900,
                        color: Color(0xFFDC2626), letterSpacing: -1)),
                const SizedBox(height: 6),
                const Text('Driver App',
                    style: TextStyle(fontSize: 16, color: Color(0xFF4B5563),
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 28, height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
