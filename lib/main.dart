import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/diary_provider.dart';
import 'screens/main_screen.dart';
import 'theme/diary_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_CN');
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  final provider = DiaryProvider();
  await provider.init();
  runApp(ChangeNotifierProvider.value(value: provider, child: const DiaryApp()));
}

class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '拾光',
      debugShowCheckedModeBanner: false,
      theme: DiaryTheme.theme,
      home: const MainScreen(),
    );
  }
}
