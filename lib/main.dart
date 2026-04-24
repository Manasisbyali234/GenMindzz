import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/services/recaptcha_service.dart';
import 'routes/app_router.dart';

const String _expectedWebOriginPort = String.fromEnvironment(
  'WEB_ALLOWED_ORIGIN_PORT',
  defaultValue: '62225',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RecaptchaService.init();
  runApp(const ProviderScope(child: GenMindzApp()));
}

class GenMindzApp extends StatelessWidget {
  const GenMindzApp({super.key});

  @override
  Widget build(BuildContext context) {
    final originError = _debugOriginError();
    if (originError != null) {
      return MaterialApp(
        title: 'GenMindz',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: _WrongOriginScreen(message: originError),
      );
    }

    return MaterialApp.router(
      title: 'GenMindz',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }

  String? _debugOriginError() {
    if (!kIsWeb || kReleaseMode) {
      return null;
    }

    final expectedPort = _expectedWebOriginPort.trim();
    if (expectedPort.isEmpty) {
      return null;
    }

    final host = Uri.base.host.toLowerCase();
    if (host != 'localhost' && host != '127.0.0.1') {
      return null;
    }

    if (Uri.base.port.toString() == expectedPort) {
      return null;
    }

    return 'This app is running from ${Uri.base.origin}, but your backend only allows '
        'http://localhost:$expectedPort. Start the app with tool/run_web_chrome.ps1 '
        'and open http://localhost:$expectedPort.';
  }
}

class _WrongOriginScreen extends StatelessWidget {
  const _WrongOriginScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wrong Web Origin',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(message, style: const TextStyle(fontSize: 16, height: 1.5)),
                const SizedBox(height: 16),
                const SelectableText(
                  '.\\tool\\run_web_chrome.ps1',
                  style: TextStyle(fontSize: 16, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 8),
                const SelectableText(
                  'http://localhost:62225',
                  style: TextStyle(fontSize: 16, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
