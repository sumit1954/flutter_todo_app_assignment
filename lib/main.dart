import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_assignment/core/router/app_router.dart';
import 'package:todo_assignment/core/theme/app_colors.dart';
import 'package:todo_assignment/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:todo_assignment/injection_container.dart' as di;
import 'package:todo_assignment/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  // Trigger the initial auth check immediately after DI is ready
  sl<AuthBloc>().add(AppStarted());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const lightColors = LightThemeColors();
    const darkColors = DarkThemeColors();

    return BlocProvider.value(
      value: sl<AuthBloc>(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Todo Assignment',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          textTheme: GoogleFonts.interTextTheme(),
          colorScheme: ColorScheme.fromSeed(
            seedColor: lightColors.primary,
            brightness: Brightness.light,
            surface: lightColors.surface,
          ),
          scaffoldBackgroundColor: lightColors.background,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          textTheme: GoogleFonts.interTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: darkColors.primary,
            brightness: Brightness.dark,
            surface: darkColors.surface,
          ),
          scaffoldBackgroundColor: darkColors.background,
        ),
        themeMode: ThemeMode.system,
        routerConfig: createRouter(),
      ),
    );
  }
}
