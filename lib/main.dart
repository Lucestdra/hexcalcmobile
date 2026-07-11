import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Phase 1 placeholder shell. The real gameplay surface, routing, theme, and
/// state machine arrive in Phase 3. This confirms the app boots portrait-only
/// with the HEX • CALC visual identity (near-black background, white wordmark).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  runApp(const HexCalcApp());
}

class HexCalcApp extends StatelessWidget {
  const HexCalcApp({super.key});

  // Design tokens land in Phase 3 (lib/core/design_system); these literals are
  // the placeholder identity for the boot screen only.
  static const Color _background = Color(0xFF05070A);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _neonBlue = Color(0xFF00BDF2);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'HEX CALC',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: _background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'HEX • CALC',
                style: TextStyle(
                  color: _primaryText,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Phase 1 — deterministic core',
                style: TextStyle(color: _neonBlue, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
