import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/miqati_theme.dart';
import 'core/localization/app_localizations.dart';
import 'features/admin/admin_controller.dart';
import 'features/home/miqati_home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (FlutterErrorDetails details) => const SizedBox.shrink();
  final origOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final msg = details.exceptionAsString();
    if (msg.contains('overflowed') || msg.contains('RenderFlex')) {
      return;
    }
    origOnError?.call(details);
  };
  runApp(const MiqatiApp());
}

class MiqatiApp extends StatefulWidget {
  const MiqatiApp({super.key});

  @override
  State<MiqatiApp> createState() => _MiqatiAppState();
}

class _MiqatiAppState extends State<MiqatiApp> {
  final MiqatiAppController controller = MiqatiAppController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, controller.audioService]),
      builder: (context, _) {
        final pal = MiqatiPalette.of(controller.isDarkMode);
        final isAr = controller.locale.languageCode == 'ar';

        return MaterialApp(
          title: controller.activeAppName,
          debugShowCheckedModeBanner: false,
          locale: controller.locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (ctx, child) {
            return Directionality(
              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            );
          },
          themeMode: controller.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: const Color(0xFF059669),
            scaffoldBackgroundColor: pal.scaffoldBg,
            cardColor: pal.cardBg,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: const Color(0xFF10B981),
            scaffoldBackgroundColor: pal.scaffoldBg,
            cardColor: pal.cardBg,
          ),
          home: MiqatiHomeShell(controller: controller),
        );
      },
    );
  }
}
