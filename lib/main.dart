import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/booking_detail_screen.dart';
import 'screens/navigation_screen.dart';
import 'screens/trip_history_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';
import 'services/driver_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';

// ─── Supabase config ──────────────────────────────────────
const String supabaseUrl    = 'https://ukxrbuxriozddhvwnrto.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVreHJidXhyaW96ZGRodnducnRvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg0MDIxNzksImV4cCI6MjA5Mzk3ODE3OX0.Zh6kI3AgPMMxe1h7SAYZHTu_A45TEgXYXQ0m7wzLFzQ';

// ─── App colours ──────────────────────────────────────────
const Color kRed    = Color(0xFFDC2626);
const Color kRedDark= Color(0xFFB91C1C);
const Color kBlue   = Color(0xFF2563EB);
const Color kBg     = Color(0xFFF9FAFB);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Supabase
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // Firebase (Conditional for Linux)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isWindows)) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
    }
  } else {
    debugPrint('Firebase is not supported natively on this platform, skipping.');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => DriverService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
      ],
      child: const AmbuLinkDriverApp(),
    ),
  );
}

class AmbuLinkDriverApp extends StatefulWidget {
  const AmbuLinkDriverApp({super.key});

  @override
  State<AmbuLinkDriverApp> createState() => _AmbuLinkDriverAppState();
}

class _AmbuLinkDriverAppState extends State<AmbuLinkDriverApp> {
  @override
  void initState() {
    super.initState();
    NotificationService.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:           'AmbuLink Driver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3:    true,
        colorSchemeSeed: kRed,
        textTheme:       GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: kBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kRed,
            foregroundColor: Colors.white,
            minimumSize:     const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: Color(0xFFF3F4F6)), // grey.shade100
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kRed, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      initialRoute:  '/splash',
      routes: {
        '/splash':         (_) => const SplashScreen(),
        '/login':          (_) => const LoginScreen(),
        '/home':           (_) => const HomeScreen(),
        '/booking-detail': (_) => const BookingDetailScreen(),
        '/navigate':       (_) => const NavigationScreen(),
        '/history':        (_) => const TripHistoryScreen(),
        '/profile':        (_) => const ProfileScreen(),
      },
    );
  }
}
