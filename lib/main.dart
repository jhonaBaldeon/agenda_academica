import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
// REVISA ESTAS RUTAS:
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/curso_viewmodel.dart';
import 'viewmodels/alumno_viewmodel.dart';
import 'viewmodels/seguimiento_viewmodel.dart';
import 'viewmodels/avance_academico_viewmodel.dart';
import 'viewmodels/rendimiento_alumno_viewmodel.dart';
import 'viewmodels/admin_viewmodel.dart';
import 'viewmodels/docentes_viewmodel.dart';
import 'views/splash_view.dart';
import 'views/login_view.dart';
import 'views/home_docente_view.dart';
import 'views/home_padre_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // Usa las opciones generadas
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CursoViewModel()),
        ChangeNotifierProvider(create: (_) => AlumnoViewModel()),
        ChangeNotifierProvider(create: (_) => SeguimientoViewModel()),
        ChangeNotifierProvider(create: (_) => AvanceAcademicoViewModel()),
        ChangeNotifierProvider(create: (_) => RendimientoAlumnoViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
        ChangeNotifierProvider(create: (_) => DocentesViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agenda Warivilcana',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromRGBO(253, 0, 2, 1),
          primary: Color.fromRGBO(253, 0, 2, 1),
          secondary: Color.fromRGBO(200, 0, 2, 1),
          surface: Color.fromRGBO(255, 235, 235, 1),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Color.fromRGBO(255, 245, 245, 1),
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromRGBO(253, 0, 2, 1),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(253, 0, 2, 1),
            foregroundColor: Colors.white,
            elevation: 3,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color.fromRGBO(253, 0, 2, 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color.fromRGBO(253, 0, 2, 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color.fromRGBO(253, 0, 2, 1), width: 2),
          ),
        ),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('es', 'ES'), Locale('en', 'US')],
      locale: Locale('es', 'ES'),
      initialRoute: '/', // El Splash decide a dónde ir
      routes: {
        '/': (context) => SplashView(),
        '/login': (context) => LoginView(),
        '/home_docente': (context) => const HomeDocenteView(),
        '/home_padre': (context) => const HomePadreView(),
      },
    );
  }
}
