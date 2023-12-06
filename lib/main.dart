import 'package:flutter/material.dart';
import 'package:nitnem/Pages/my_home-page.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nitnem',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,  // This line sets the theme mode to follow the system theme
      theme: ThemeData(
        // Define your light theme here
        brightness: Brightness.light,
        // Other theme configurations...
      ),
      darkTheme: ThemeData(
        // Define your dark theme here
        brightness: Brightness.dark,
        // Other dark theme configurations...
      ),
      home: const MyHomePage(title: "Nitnem"),
    );
  }
}


